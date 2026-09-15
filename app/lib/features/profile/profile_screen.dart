import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../core/theme/tab_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/extensions/l10n_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/app_providers.dart';
import '../../core/profile/profile_repository.dart';
import '../../core/database/app_database.dart';
import 'package:go_router/go_router.dart';
import '../phonetics/widgets/phoneme_heatmap_widget.dart';
import '../../core/widgets/voice_evolution_card.dart';
import '../../core/widgets/coach_marks.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey _kCoachHeader = GlobalKey();
  final GlobalKey _kCoachReadiness = GlobalKey();
  final GlobalKey _kCoachHeatmap = GlobalKey();
  final GlobalKey _kCoachVoiceEvolution = GlobalKey();

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _animController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowCoach());
  }

  Future<void> _maybeShowCoach() async {
    final cache = ref.read(localCacheProvider);
    if (await cache.hasSeenCoach('profile_screen')) return;
    if (!mounted) return;
    await showCoachMarks(
      context,
      [
        CoachStep(
          targetKey: _kCoachHeader,
          title: 'Tu Perfil y Metas Profesionales',
          body: 'Configura tu rol (Software Engineer, DevOps, etc.) y nivel objetivo (B2/C1). El Coach IA adaptará los ejemplos y preguntas a tu meta.',
        ),
        CoachStep(
          targetKey: _kCoachReadiness,
          title: 'Readiness y Cobertura Integral',
          body: 'Calcula tu balance de competencias entre Gramática, Vocabulario Técnico, STAR Speaking y Comprensión para garantizar un avance equilibrado.',
        ),
        CoachStep(
          targetKey: _kCoachHeatmap,
          title: 'Mapa de Calor de 44 Fonemas',
          body: 'Mapeo acústico de cada fonema del inglés con análisis de confianza Wilson al 95%. Detecta exactamente qué sonidos requieren refuerzo.',
        ),
        CoachStep(
          targetKey: _kCoachVoiceEvolution,
          title: 'Evolución de Voz: Día 1 vs Hoy',
          body: 'Compara tus primeras grabaciones con tu producción actual para comprobar tu mejora en fluidez, reducción de acento y seguridad oral.',
        ),
      ],
      accent: TabTheme.profile.accent,
    );
    await cache.markCoachSeen('profile_screen');
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _showUserSwitchModal(BuildContext context, List<UserProfilesLocalData> users, String currentId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.people_alt_rounded, color: AppTheme.primary, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      context.l10n.profileSwitchUserTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.close, color: AppTheme.textSecondary, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  context.l10n.profileSwitchUserBody,
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 16),
                ...users.map((u) {
                  final isSelected = u.id == currentId;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.surfaceLight : AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : AppTheme.border,
                        width: isSelected ? 1.8 : 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: isSelected ? AppTheme.primary : AppTheme.surfaceLight,
                        child: Text(
                          u.displayName.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: isSelected ? Colors.black : AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            u.displayName,
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              u.targetLevel,
                              style: const TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        '${u.roleTitle} • ${u.totalXp} XP',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: AppTheme.primary)
                          : Icon(Icons.radio_button_unchecked_rounded, color: AppTheme.textSecondary),
                      onTap: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final switchedMsg = context.l10n.profileSwitchedTo(u.displayName);
                        
                        // Check if user has PIN
                        final secure = ref.read(secureStorageProvider);
                        final hasPin = await secure.hasPin(u.id);
                        if (u.id != currentId) {
                          if (hasPin) {
                            final expectedPin = await secure.getPin(u.id);
                            if (!context.mounted) return;
                            final ok = await _promptUserPin(context, u.displayName, expectedPin, u.id);
                            if (!ok) return;
                          } else {
                            if (!context.mounted) return;
                            await _showChangePinDialog(context, u.id, u.displayName);
                            final newlySetPin = await secure.hasPin(u.id);
                            if (!newlySetPin) return;
                          }
                        }

                        if (!context.mounted) return;
                        Navigator.pop(ctx);
                        ref.read(activeUserIdProvider.notifier).state = u.id;
                        await ref.read(profileRepositoryProvider).switchUser(u.id);
                        await ref.read(secureStorageProvider).saveActiveUserId(u.id);
                        unawaited(ref.read(apiClientProvider).reauthenticateAs(u.id).catchError((_) {}));
                        ref.invalidate(profileSummaryProvider);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(switchedMsg),
                            backgroundColor: AppTheme.surfaceLight,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  );
                }),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    side: BorderSide(color: AppTheme.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.add_rounded, color: AppTheme.primary, size: 20),
                  label: Text(context.l10n.profileCreateNew, style: TextStyle(color: AppTheme.textPrimary)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showCreateUserDialog(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _promptUserPin(BuildContext context, String userName, String? expectedPin, String userId) async {
    final pinCtrl = TextEditingController();
    String? error;
    bool validating = false;
    final res = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.lock_rounded, color: AppTheme.primary, size: 22),
              const SizedBox(width: 8),
              Text('Introduce tu PIN', style: TextStyle(color: AppTheme.textPrimary, fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Acceso al perfil de $userName',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pinCtrl,
                autofocus: true,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textPrimary, letterSpacing: 8, fontSize: 20, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'PIN',
                  counterText: '',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  errorText: error,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: Text('Cancelar', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
              onPressed: validating
                  ? null
                  : () async {
                      final pin = pinCtrl.text.trim();
                      if (pin.length < 4) {
                        setDialogState(() => error = 'El PIN debe tener al menos 4 dígitos');
                        return;
                      }
                      setDialogState(() {
                        validating = true;
                        error = null;
                      });
                      if (expectedPin != null && expectedPin.isNotEmpty) {
                        if (pin == expectedPin) {
                          if (dialogCtx.mounted) Navigator.pop(dialogCtx, true);
                          return;
                        }
                      }
                      final api = ref.read(apiClientProvider);
                      final ok = await api.verifyUserPin(userId, pin);
                      if (ok) {
                        await ref.read(secureStorageProvider).savePin(userId, pin);
                        if (dialogCtx.mounted) Navigator.pop(dialogCtx, true);
                      } else {
                        setDialogState(() {
                          validating = false;
                          error = 'PIN incorrecto';
                        });
                      }
                    },
              child: validating
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : const Text('Acceder', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
    return res ?? false;
  }

  Future<void> _showChangePinDialog(BuildContext context, String userId, String userName) async {
    final secure = ref.read(secureStorageProvider);
    final hasExisting = await secure.hasPin(userId);
    final existingPin = hasExisting ? await secure.getPin(userId) : null;

    final currentPinCtrl = TextEditingController();
    final newPinCtrl = TextEditingController();
    final confirmPinCtrl = TextEditingController();
    String? error;

    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.lock_outline_rounded, color: AppTheme.primary, size: 22),
              const SizedBox(width: 8),
              Text(hasExisting ? 'PIN de Seguridad' : 'Establecer PIN', style: TextStyle(color: AppTheme.textPrimary, fontSize: 16)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Configura un código PIN (4 dígitos) para proteger el perfil de $userName al iniciar o cambiar de cuenta.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 16),
                if (hasExisting) ...[
                  TextField(
                    controller: currentPinCtrl,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: TextStyle(color: AppTheme.textPrimary, letterSpacing: 4),
                    decoration: InputDecoration(
                      labelText: 'PIN actual',
                      counterText: '',
                      prefixIcon: const Icon(Icons.password_rounded, color: AppTheme.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: newPinCtrl,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: TextStyle(color: AppTheme.textPrimary, letterSpacing: 4),
                  decoration: InputDecoration(
                    labelText: 'Nuevo PIN (4 dígitos)',
                    counterText: '',
                    prefixIcon: const Icon(Icons.pin_rounded, color: AppTheme.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPinCtrl,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: TextStyle(color: AppTheme.textPrimary, letterSpacing: 4),
                  decoration: InputDecoration(
                    labelText: 'Confirmar nuevo PIN',
                    counterText: '',
                    prefixIcon: const Icon(Icons.check_rounded, color: AppTheme.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                if (error != null) ...[
                  const SizedBox(height: 10),
                  Text(error!, style: const TextStyle(color: AppTheme.error, fontSize: 12)),
                ],
              ],
            ),
          ),
          actions: [
            if (hasExisting)
              TextButton(
                onPressed: () async {
                  if (currentPinCtrl.text.trim() != existingPin) {
                    setDialogState(() => error = 'El PIN actual es incorrecto');
                    return;
                  }
                  await secure.removePin(userId);
                  if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('PIN eliminado. El perfil ya no requiere código.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: const Text('Quitar PIN', style: TextStyle(color: AppTheme.error)),
              ),
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text('Cancelar', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
              onPressed: () async {
                if (hasExisting && currentPinCtrl.text.trim() != existingPin) {
                  setDialogState(() => error = 'El PIN actual no coincide');
                  return;
                }
                final np = newPinCtrl.text.trim();
                final cp = confirmPinCtrl.text.trim();
                if (np.length < 4) {
                  setDialogState(() => error = 'El PIN debe tener al menos 4 dígitos');
                  return;
                }
                if (np != cp) {
                  setDialogState(() => error = 'Los PIN nuevos no coinciden');
                  return;
                }
                await secure.savePin(userId, np);
                unawaited(ref.read(apiClientProvider).setUserPin(userId, np).catchError((_) => false));
                if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('PIN para $userName guardado con éxito.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Guardar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateUserDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController(text: 'Senior Tech & Cloud Engineer');
    final pinCtrl = TextEditingController();
    String level = 'B2';
    String goal = 'interview_prep';

    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(context.l10n.profileNewProfile, style: TextStyle(color: AppTheme.textPrimary)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  style: TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: context.l10n.profileNameAlias,
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: roleCtrl,
                  style: TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: context.l10n.profileRoleSpecialty,
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: goal,
                  dropdownColor: AppTheme.surfaceLight,
                  style: TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Objetivo de Aprendizaje (Foco IA)',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'interview_prep', child: Text('Entrevistas y Fluidez General (Todo en uno)')),
                    DropdownMenuItem(value: 'interviews', child: Text('Preparación para Entrevistas de Trabajo')),
                    DropdownMenuItem(value: 'general_fluency', child: Text('Conversación y Fluidez del Día a Día')),
                    DropdownMenuItem(value: 'daily_meetings', child: Text('Reuniones de Trabajo y Comunicación')),
                    DropdownMenuItem(value: 'technical_career', child: Text('Inglés Técnico y Profesional')),
                  ],
                  onChanged: isSubmitting
                      ? null
                      : (val) {
                          if (val != null) setDialogState(() => goal = val);
                        },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: level,
                  dropdownColor: AppTheme.surfaceLight,
                  style: TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: context.l10n.profileTargetCefr,
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: ['A2', 'B1', 'B2', 'C1'].map((l) {
                    return DropdownMenuItem(value: l, child: Text(l));
                  }).toList(),
                  onChanged: isSubmitting
                      ? null
                      : (val) {
                          if (val != null) setDialogState(() => level = val);
                        },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pinCtrl,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: TextStyle(color: AppTheme.textPrimary, letterSpacing: 4),
                  decoration: InputDecoration(
                    labelText: 'PIN de acceso (opcional, 4 dígitos)',
                    counterText: '',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(dialogCtx),
              child: Text(context.l10n.actionCancel, style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) return;
                      setDialogState(() => isSubmitting = true);
                      try {
                        final repo = ref.read(profileRepositoryProvider);
                        final newUser = await repo.createUser(
                          displayName: name,
                          roleTitle: roleCtrl.text.trim().isNotEmpty ? roleCtrl.text.trim() : 'English Learner',
                          targetLevel: level,
                          learningGoal: goal,
                          dailyGoalMinutes: 20,
                        );
                        final pin = pinCtrl.text.trim();
                        if (pin.isNotEmpty) {
                          await ref.read(secureStorageProvider).savePin(newUser.id, pin);
                          unawaited(ref.read(apiClientProvider).setUserPin(newUser.id, pin).catchError((_) => false));
                        }
                        if (dialogCtx.mounted) {
                          Navigator.pop(dialogCtx);
                        }
                        ref.read(activeUserIdProvider.notifier).state = newUser.id;
                        await repo.switchUser(newUser.id);
                        await ref.read(secureStorageProvider).saveActiveUserId(newUser.id);
                        ref.invalidate(profileSummaryProvider);
                        ref.invalidate(activeProfileProvider);
                      } catch (e) {
                        setDialogState(() => isSubmitting = false);
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : Text(context.l10n.actionCreate, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLearningGoal(String goal) {
    switch (goal) {
      case 'all_around':
      case 'interview_prep':
        return 'Entrevistas y Fluidez General';
      case 'interviews':
        return 'Preparación para Entrevistas';
      case 'daily_fluency':
      case 'general_fluency':
        return 'Conversación y Fluidez Diaria';
      case 'workplace':
      case 'daily_meetings':
        return 'Reuniones y Trabajo en Equipo';
      case 'technical_career':
      case 'system_design':
      case 'client_negotiation':
        return 'Inglés Técnico y Profesional';
      default:
        return 'Entrevistas y Fluidez General';
    }
  }

  void _showEditProfileDialog(BuildContext context, UserProfilesLocalData user) {
    final nameCtrl = TextEditingController(text: user.displayName);
    final roleCtrl = TextEditingController(text: user.roleTitle);
    String level = user.targetLevel;
    const validGoals = ['interview_prep', 'interviews', 'general_fluency', 'daily_meetings', 'technical_career'];
    String goal = validGoals.contains(user.learningGoal) ? user.learningGoal : 'interview_prep';
    int minutes = user.dailyGoalMinutes;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Personalizar Perfil & Foco de IA', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  style: TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: context.l10n.profileNameAlias,
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: roleCtrl,
                  style: TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: context.l10n.profileRoleSpecialty,
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: goal,
                  dropdownColor: AppTheme.surfaceLight,
                  style: TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Objetivo de Aprendizaje (Foco IA)',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'interview_prep', child: Text('Entrevistas y Fluidez General (Todo en uno)')),
                    DropdownMenuItem(value: 'interviews', child: Text('Preparación para Entrevistas de Trabajo')),
                    DropdownMenuItem(value: 'general_fluency', child: Text('Conversación y Fluidez del Día a Día')),
                    DropdownMenuItem(value: 'daily_meetings', child: Text('Reuniones de Trabajo y Comunicación')),
                    DropdownMenuItem(value: 'technical_career', child: Text('Inglés Técnico y Profesional')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => goal = val);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: level,
                  dropdownColor: AppTheme.surfaceLight,
                  style: TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: context.l10n.profileTargetCefr,
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: ['A2', 'B1', 'B2', 'C1'].map((l) {
                    return DropdownMenuItem(value: l, child: Text(l));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => level = val);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: minutes,
                  dropdownColor: AppTheme.surfaceLight,
                  style: TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Meta Diaria de Práctica',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: [10, 15, 20, 30].map((m) {
                    return DropdownMenuItem(value: m, child: Text('$m min / día'));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => minutes = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(context.l10n.actionCancel, style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: TabTheme.profile.accent),
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final role = roleCtrl.text.trim();
                if (name.isEmpty) return;

                await ref.read(profileRepositoryProvider).updateUserProfile(
                      userId: user.id,
                      displayName: name,
                      roleTitle: role.isNotEmpty ? role : 'Software Engineer',
                      targetLevel: level,
                      learningGoal: goal,
                      dailyGoalMinutes: minutes,
                    );
                if (dialogCtx.mounted) {
                  Navigator.pop(dialogCtx);
                }
                ref.invalidate(profileSummaryProvider);
                ref.invalidate(activeProfileProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Perfil y foco de IA actualizados para $name'),
                      backgroundColor: AppTheme.surfaceLight,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Guardar Cambios', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppTheme.error, size: 24),
            const SizedBox(width: 8),
            Text('¿Reiniciar a Cero?', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Text(
          'Esto pondrá a 0 tus puntos de XP, racha, historial y mapa de calor en este dispositivo y en el servidor, dejándote un entorno 100% limpio para empezar a registrar tu uso real.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(context.l10n.actionCancel, style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              Navigator.pop(context); // close bottom sheet
              await ref.read(profileRepositoryProvider).resetToFreshStart();
              ref.invalidate(profileSummaryProvider);
              ref.invalidate(activeProfileProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Progreso reiniciado a 0 correctamente.'),
                    backgroundColor: AppTheme.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Sí, Reiniciar Todo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeUserId = ref.watch(activeUserIdProvider);
    final summaryAsync = ref.watch(profileSummaryProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: summaryAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          ),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: AppTheme.error, size: 40),
                const SizedBox(height: 12),
                Text(context.l10n.profileLoadError(err.toString()), style: TextStyle(color: AppTheme.textSecondary)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.refresh(profileSummaryProvider),
                  child: Text(context.l10n.errorRetry),
                ),
              ],
            ),
          ),
          data: (summary) {
            final isEn = ref.watch(localeProvider).languageCode == 'en';
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: RefreshIndicator(
                  color: TabTheme.profile.accent,
                  onRefresh: () async {
                    ref.invalidate(profileSummaryProvider);
                    await ref.read(profileSummaryProvider.future);
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Header Block (Discreet gradient + Avatar + CEFR + Switcher)
                        KeyedSubtree(
                          key: _kCoachHeader,
                          child: _buildHeaderBlock(context, summary, activeUserId),
                        ),
                        const SizedBox(height: 20),

                        // 2. Global Progress (XP, Weekly, Streak, Total Time with Count-up)
                        _buildGlobalProgressBlock(summary, isEn),
                        const SizedBox(height: 20),

                        // 3. Quick Stats Grid (Key learning metrics with Comprehension & FSRS)
                        _buildQuickStatsGrid(summary, isEn),
                        const SizedBox(height: 24),

                        // 4. Cobertura y Progreso por Módulos (Simulador STAR, Vocabulario, Gramática, Comprensión, FSRS)
                        KeyedSubtree(
                          key: _kCoachReadiness,
                          child: _buildModuleCoverageCard(summary, isEn),
                        ),
                        const SizedBox(height: 24),

                        // 5. Activity Calendar & Heatmap (7d bars + 30d matrix + highlight today)
                        _buildActivityCalendarBlock(summary),
                        const SizedBox(height: 24),

                        // 6. Evaluación Fonética V2 (Mapa 44 Fonemas, Wilson LB 95% y HVPT) - Compact Mode
                        KeyedSubtree(
                          key: _kCoachHeatmap,
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: TabTheme.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: TabTheme.surfaceContainerHigh),
                              boxShadow: TabTheme.cardShadow,
                            ),
                            child: const PhonemeHeatmapWidget(compact: true),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 7. Evolucion de voz (baseline "Dia 1 vs Hoy")
                        KeyedSubtree(
                          key: _kCoachVoiceEvolution,
                          child: const VoiceEvolutionCard(),
                        ),
                        const SizedBox(height: 24),
                      ],

                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. Header Block
  // ===========================================================================
  Widget _buildHeaderBlock(BuildContext context, ProfileSummaryData summary, String activeUserId) {
    final user = summary.profile;
    final isOnline = summary.syncStatus == 'synced';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TabTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: TabTheme.surfaceContainerHigh),
        boxShadow: TabTheme.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with Level Ring
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: TabTheme.profile.accent, width: 2.2),
                      color: TabTheme.profile.container,
                    ),
                    child: Center(
                      child: Text(
                        user.displayName.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: TabTheme.profile.accent,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: TabTheme.profile.accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      user.targetLevel,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              // Name, Role & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.displayName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.verified_rounded, size: 16, color: TabTheme.profile.accent),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.roleTitle,
                      style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Goal & Sync status chips
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: TabTheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: TabTheme.surfaceContainerHigh),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.flag_rounded, size: 12, color: TabTheme.profile.accent),
                              const SizedBox(width: 4),
                              Text(
                                '${user.dailyGoalMinutes} min/día',
                                style: TextStyle(fontSize: 11, color: AppTheme.textPrimary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isOnline
                                ? (AppTheme.isLight ? const Color(0xFFE8F5E9) : const Color(0xFF042018))
                                : (AppTheme.isLight ? const Color(0xFFFFF3E0) : const Color(0xFF281806)),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isOnline
                                  ? AppTheme.success.withValues(alpha: 0.5)
                                  : AppTheme.warning.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isOnline ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                                size: 12,
                                color: isOnline ? AppTheme.success : AppTheme.warning,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isOnline ? 'NAS Synced' : 'Offline Mode',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isOnline ? AppTheme.success : AppTheme.warning,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Settings Action
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: TabTheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: Icon(Icons.settings_outlined, color: TabTheme.profile.accent, size: 20),
                tooltip: context.l10n.profileSystemAccountConfig,
                onPressed: () => _showSettingsBottomSheet(context, summary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSettingsBottomSheet(BuildContext context, ProfileSummaryData summary) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Center(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.92,
            maxWidth: 640,
          ),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.tune_rounded, color: TabTheme.profile.accent, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        context.l10n.profileSystemAccountConfig,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: AppTheme.textSecondary, size: 22),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              Divider(color: AppTheme.border, height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: _buildSettingsSection(ctx, summary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 2. Global Progress Block with Count-Up
  // ===========================================================================
  Widget _buildGlobalProgressBlock(ProfileSummaryData summary, bool isEn) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TabTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TabTheme.surfaceContainerHigh),
        boxShadow: TabTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt_rounded, size: 18, color: TabTheme.profile.accent),
              const SizedBox(width: 6),
              Text(
                context.l10n.profileGlobalProgress,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Total XP
              Expanded(
                child: _buildCountUpMetric(
                  label: 'Total XP',
                  value: summary.totalXp,
                  suffix: '',
                  color: TabTheme.profile.accent,
                  icon: Icons.stars_rounded,
                ),
              ),
              Container(width: 1, height: 45, color: TabTheme.surfaceContainerHigh),
              // Weekly XP
              Expanded(
                child: _buildCountUpMetric(
                  label: isEn ? 'Weekly XP' : 'XP Semanal',
                  value: summary.weeklyXp,
                  suffix: '',
                  color: TabTheme.speaking.accent,
                  icon: Icons.trending_up_rounded,
                ),
              ),
              Container(width: 1, height: 45, color: TabTheme.surfaceContainerHigh),
              // Streak
              Expanded(
                child: _buildCountUpMetric(
                  label: isEn ? 'Streak' : 'Racha',
                  value: summary.streakDays,
                  suffix: 'd',
                  color: const Color(0xFFFF6D00),
                  icon: Icons.local_fire_department_rounded,
                ),
              ),
              Container(width: 1, height: 45, color: TabTheme.surfaceContainerHigh),
              // Total Time
              Expanded(
                child: _buildCountUpMetric(
                  label: isEn ? 'Time' : 'Tiempo',
                  value: summary.totalMinutes ~/ 60,
                  suffix: 'h',
                  color: TabTheme.vocabulary.accent,
                  icon: Icons.timer_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountUpMetric({
    required String label,
    required int value,
    required String suffix,
    required Color color,
    required IconData icon,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutExpo,
      builder: (context, animatedVal, child) {
        return Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(
              '${animatedVal.toInt()}$suffix',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // 3. Quick Stats Grid (2x3)
  // ===========================================================================
  Widget _buildQuickStatsGrid(ProfileSummaryData summary, bool isEn) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.profileKeyMetrics,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: isEn ? 'STAR Sessions' : 'Sesiones STAR',
                value: '${summary.totalSessions}',
                sub: isEn ? 'Interviews & Drills' : 'Entrevistas & Drills',
                icon: Icons.laptop_chromebook_rounded,
                accentColor: TabTheme.speaking.accent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                title: isEn ? 'CEFR Grammar' : 'Gramática CEFR',
                value: '${summary.completedUnits} / 32',
                sub: isEn ? 'Units completed' : 'Unidades superadas',
                icon: Icons.checklist_rounded,
                accentColor: TabTheme.grammar.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: isEn ? 'Mastered Vocab' : 'Vocabulario Dominado',
                value: '${summary.masteredWords}',
                sub: isEn ? 'Memorized words' : 'Palabras memorizadas',
                icon: Icons.auto_stories_rounded,
                accentColor: TabTheme.vocabulary.accent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                title: isEn ? 'Reading & Audio' : 'Comprensión & Audio',
                value: '${(summary.listeningScore > 0 ? (summary.listeningScore * 12 ~/ 100) : 0)} / 12',
                sub: isEn ? 'Reading & Listening' : 'Lectura & Listening',
                icon: Icons.headphones_rounded,
                accentColor: TabTheme.comprehension.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: isEn ? 'Global Accuracy' : 'Precisión Global',
                value: '${summary.speakingClarityScore > 0 ? summary.speakingClarityScore : summary.skills.grammarScore}%',
                sub: isEn ? 'Test pass rate' : 'Tasa acierto test',
                icon: Icons.verified_rounded,
                accentColor: const Color(0xFF059669),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                title: isEn ? 'FSRS Retention' : 'Retención FSRS',
                value: '${summary.masteredWords > 0 ? ((summary.masteredWords / 50.0).clamp(0.0, 1.0) * 100).round() : 0}%',
                sub: isEn ? 'Memory stability' : 'Estabilidad de memoria',
                icon: Icons.layers_rounded,
                accentColor: TabTheme.fsrs.accent,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String sub,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TabTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TabTheme.surfaceContainerHigh),
        boxShadow: TabTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: accentColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: TextStyle(fontSize: 11, color: accentColor.withValues(alpha: 0.85)),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 5. Module Coverage & Learning Progress
  // ===========================================================================
  Widget _buildModuleCoverageCard(ProfileSummaryData summary, bool isEn) {
    final grammarProgress = (summary.completedUnits / 32.0).clamp(0.06, 1.0);
    final vocabProgress = (summary.masteredWords / 150.0).clamp(0.06, 1.0);
    final speakingProgress = (summary.speakingClarityScore / 100.0).clamp(0.06, 1.0);

    // Compresión: cobertura (piezas completadas / 12) × accuracy media
    // Da 0 si no has hecho nada, y sube de forma realista.
    // Total de piezas en el currículum = 12
    const totalPieces = 12;
    final coverageRatio = (summary.completedPieces / totalPieces).clamp(0.0, 1.0);
    final accuracyRatio = summary.avgComprehensionScore > 0
        ? (summary.avgComprehensionScore / 100.0).clamp(0.0, 1.0)
        : 0.0;
    // Progreso real = cobertura * 0.6 + accuracy * 0.4 (cobertura pesa más)
    final compProgress = summary.completedPieces == 0
        ? 0.06  // valor mínimo para que la barra no sea invisible
        : (coverageRatio * 0.6 + accuracyRatio * 0.4).clamp(0.06, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TabTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TabTheme.surfaceContainerHigh),
        boxShadow: TabTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.dashboard_customize_rounded, size: 18, color: TabTheme.profile.accent),
              const SizedBox(width: 8),
              Text(
                isEn ? 'Module Coverage & Progress' : 'Cobertura y Progreso por Módulos',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const Spacer(),
              Text(
                'CEFR ~ ${summary.profile.targetLevel}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: TabTheme.profile.accent),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isEn ? 'Comprehensive technical curriculum in your plan' : 'Currículum técnico integral activo en tu plan',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          _buildModuleProgressRow(
            title: isEn ? 'STAR Simulator & Fluency' : 'Simulador STAR & Fluidez',
            detail: isEn ? '13 categories · 215 questions' : '13 categorías · 215 preguntas',
            stat: '${summary.speakingClarityScore}% ${isEn ? 'fluency' : 'fluidez'}',
            color: TabTheme.speaking.accent,
            icon: Icons.mic_rounded,
            progress: speakingProgress,
          ),
          const SizedBox(height: 14),
          _buildModuleProgressRow(
            title: isEn ? 'Technical Vocabulary' : 'Vocabulario Técnico',
            detail: isEn ? '44 packs · 450+ terms' : '44 packs · 450+ términos',
            stat: '${summary.masteredWords} ${isEn ? 'mastered' : 'dominadas'}',
            color: TabTheme.vocabulary.accent,
            icon: Icons.auto_stories_rounded,
            progress: vocabProgress,
          ),
          const SizedBox(height: 14),
          _buildModuleProgressRow(
            title: isEn ? 'Structural Grammar' : 'Gramática Estructural',
            detail: isEn ? '32 units · 4 CEFR levels (A1-C1)' : '32 unidades · 4 niveles CEFR (A1-C1)',
            stat: '${summary.completedUnits}/32 ${isEn ? 'passed' : 'superadas'}',
            color: TabTheme.grammar.accent,
            icon: Icons.spellcheck_rounded,
            progress: grammarProgress,
          ),
          const SizedBox(height: 14),
          _buildModuleProgressRow(
            title: isEn ? 'Reading & Audio Comprehension' : 'Comprensión Lectora & Audio',
            detail: isEn ? '12 pieces · Bilingual texts + Audio' : '12 piezas · Textos bilingües + Audio',
            stat: summary.completedPieces == 0
                ? (isEn ? '0/12 pieces' : '0/12 piezas')
                : '${summary.completedPieces}/12 ${isEn ? 'pieces' : 'piezas'}'  
                  ' · ${summary.avgComprehensionScore}%',
            color: TabTheme.comprehension.accent,
            icon: Icons.headphones_rounded,
            progress: compProgress,
          ),
          const SizedBox(height: 14),
          _buildModuleProgressRow(
            title: isEn ? 'FSRS Review Deck' : 'Mazo de Repaso FSRS',
            detail: isEn ? 'Adaptive forgetting curve v5' : 'Curva del olvido adaptativa v5',
            stat: '${(vocabProgress * 100).round()}% ${isEn ? 'retention' : 'retención'}',
            color: TabTheme.fsrs.accent,
            icon: Icons.layers_rounded,
            progress: vocabProgress,
          ),
        ],
      ),
    );
  }

  Widget _buildModuleProgressRow({
    required String title,
    required String detail,
    required String stat,
    required Color color,
    required IconData icon,
    required double progress,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 15),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  Text(
                    detail,
                    style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            Text(
              stat,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress.clamp(0.04, 1.0),
            minHeight: 6,
            backgroundColor: TabTheme.surfaceContainerLow,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 6. Activity Calendar & Heatmap (7d + 30d with Today Highlight)
  // ===========================================================================
  Widget _buildActivityCalendarBlock(ProfileSummaryData summary) {
    final weekly = summary.weeklyActivity;
    final activity30d = summary.activity30d;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TabTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TabTheme.surfaceContainerHigh),
        boxShadow: TabTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month_rounded, size: 18, color: TabTheme.profile.accent),
              const SizedBox(width: 8),
              Text(
                context.l10n.profileConsistencyActivity,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: TabTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  context.l10n.profileLast30Days,
                  style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 7-day Bar chart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: weekly.map((w) {
              final isToday = w == weekly.last;
              final xp = (w['xp'] as num?)?.toInt() ?? 0;
              final heightPct = (xp / 60.0).clamp(0.12, 1.0);

              return Column(
                children: [
                  Text(
                    xp > 0 ? '+$xp' : '0',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isToday ? TabTheme.profile.accent : AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 28,
                    height: 50 * heightPct,
                    decoration: BoxDecoration(
                      color: isToday
                          ? TabTheme.profile.accent
                          : (xp > 0 ? TabTheme.profile.accent.withValues(alpha: 0.4) : TabTheme.surfaceContainerLow),
                      borderRadius: BorderRadius.circular(8),
                      border: isToday ? Border.all(color: Colors.white, width: 1.2) : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    w['day'] as String? ?? '',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday ? TabTheme.profile.accent : AppTheme.textSecondary,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),

          const SizedBox(height: 18),
          Divider(color: TabTheme.surfaceContainerHigh, height: 1),
          const SizedBox(height: 14),

          // 30-Day Mini Heatmap Grid
          Row(
            children: [
              Text(
                context.l10n.profileHeatmap30,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
              ),
              const Spacer(),
              Text(
                context.l10n.profileLess,
                style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
              ),
              const SizedBox(width: 4),
              _HeatmapLegendBox(color: TabTheme.surfaceContainerLow),
              const SizedBox(width: 3),
              _HeatmapLegendBox(color: TabTheme.profile.accent.withValues(alpha: 0.3)),
              const SizedBox(width: 3),
              _HeatmapLegendBox(color: TabTheme.profile.accent.withValues(alpha: 0.65)),
              const SizedBox(width: 3),
              _HeatmapLegendBox(color: TabTheme.profile.accent),
              const SizedBox(width: 4),
              Text(
                context.l10n.profileMore,
                style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: List.generate(30, (idx) {
              final isToday = idx == 29;
              final act = idx < activity30d.length ? activity30d[idx] : null;
              final xp = act?.xpEarned ?? 0;

              Color cellColor = TabTheme.surfaceContainerLow;
              if (xp > 35) {
                cellColor = TabTheme.profile.accent;
              } else if (xp > 15) {
                cellColor = TabTheme.profile.accent.withValues(alpha: 0.65);
              } else if (xp > 0) {
                cellColor = TabTheme.profile.accent.withValues(alpha: 0.3);
              }

              return Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: cellColor,
                  borderRadius: BorderRadius.circular(5),
                  border: isToday
                      ? Border.all(color: Colors.white, width: 1.8)
                      : null,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 7. Settings Section
  // ===========================================================================
  Future<void> _showServerConfig(BuildContext context) async {
    final cache = ref.read(localCacheProvider);
    final secure = ref.read(secureStorageProvider);
    final urlCtrl = TextEditingController(text: await cache.getBaseUrl());
    final keyCtrl = TextEditingController(text: (await secure.getApiKey()) ?? '');
    String? statusMsg;
    bool isChecking = false;

    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.dns_rounded, color: TabTheme.profile.accent, size: 22),
              const SizedBox(width: 8),
              Text('Servidor NAS & Sincronización', style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Servidor de la app. Normalmente no necesitas cambiar esto.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 12),
                // Botón preset rápido NAS LAN
                Wrap(
                  spacing: 6,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.public_rounded, size: 14, color: AppTheme.primary),
                      label: const Text('Servidor por defecto', style: TextStyle(fontSize: 11)),
                      onPressed: () {
                        setDialogState(() {
                          urlCtrl.text = 'https://ingles.ivanjonasfc.dev';
                          if (keyCtrl.text.isEmpty) keyCtrl.text = 'super-secret-key-123';
                        });
                      },
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.lan_rounded, size: 14, color: AppTheme.primary),
                      label: const Text('NAS local (misma red)', style: TextStyle(fontSize: 11)),
                      onPressed: () {
                        setDialogState(() {
                          urlCtrl.text = 'http://192.168.0.200:8092';
                          if (keyCtrl.text.isEmpty) keyCtrl.text = 'super-secret-key-123';
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlCtrl,
                  style: TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'URL del Servidor',
                    prefixIcon: Icon(Icons.dns_rounded, color: AppTheme.primary),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: keyCtrl,
                  style: TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'API Key',
                    prefixIcon: Icon(Icons.key_rounded, color: AppTheme.primary),
                  ),
                ),
                if (statusMsg != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusMsg!.contains('200') || statusMsg!.contains('OK') || statusMsg!.contains('éxito')
                          ? AppTheme.success.withValues(alpha: 0.12)
                          : AppTheme.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: statusMsg!.contains('200') || statusMsg!.contains('OK') || statusMsg!.contains('éxito')
                            ? AppTheme.success.withValues(alpha: 0.4)
                            : AppTheme.error.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      statusMsg!,
                      style: TextStyle(
                        fontSize: 12,
                        color: statusMsg!.contains('200') || statusMsg!.contains('OK') || statusMsg!.contains('éxito')
                            ? AppTheme.success
                            : AppTheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text('Cerrar', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            OutlinedButton(
              onPressed: isChecking ? null : () async {
                setDialogState(() {
                  isChecking = true;
                  statusMsg = 'Conectando con el NAS...';
                });
                try {
                  await cache.saveBaseUrl(urlCtrl.text.trim());
                  await secure.saveApiKey(keyCtrl.text.trim());
                  final api = ref.read(apiClientProvider);
                  final health = await api.checkHealthDetailed();
                  final syncRes = await ref.read(databaseSyncServiceProvider).syncAll();
                  ref.invalidate(profileSummaryProvider);
                  ref.invalidate(activeProfileProvider);
                  setDialogState(() {
                    isChecking = false;
                    statusMsg = '¡Conectado! Latencia: ${health['latency_ms']} ms · ${syncRes.message}';
                  });
                } catch (e) {
                  setDialogState(() {
                    isChecking = false;
                    statusMsg = 'Error al conectar: $e';
                  });
                }
              },
              child: isChecking
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Probar & Sincronizar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
              onPressed: () async {
                await cache.saveBaseUrl(urlCtrl.text.trim());
                await secure.saveApiKey(keyCtrl.text.trim());
                ref.invalidate(profileSummaryProvider);
                ref.invalidate(activeProfileProvider);
                if (dialogCtx.mounted) Navigator.pop(dialogCtx);
              },
              child: const Text('Guardar',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, ProfileSummaryData summary) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
            child: Row(
              children: [
                Icon(Icons.settings_rounded, size: 18, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                Text(
                  context.l10n.profileSystemAccountConfig,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
              ],
            ),
          ),
          Divider(color: AppTheme.border, height: 1),

          // Language selector (i18n)
          Consumer(
            builder: (context, ref, _) {
              final currentLocale = ref.watch(localeProvider);
              final isEn = currentLocale.languageCode == 'en';
              return ListTile(
                leading: const Icon(Icons.language_rounded, color: AppTheme.primary, size: 22),
                title: Text(context.l10n.profileLanguage,
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
                subtitle: Text(isEn ? context.l10n.profileLanguageEn : context.l10n.profileLanguageEs,
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                trailing: Text(isEn ? 'EN' : 'ES',
                    style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                onTap: () async {
                  final next = isEn ? 'es' : 'en';
                  ref.read(localeProvider.notifier).state = Locale(next);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('app_locale', next);
                },
              );
            },
          ),
          Divider(color: AppTheme.border, height: 1),

          // Tema claro / oscuro
          Consumer(
            builder: (context, ref, _) {
              final isLight = ref.watch(themeIsLightProvider);
              final isEn = ref.watch(localeProvider).languageCode == 'en';
              return SwitchListTile(
                secondary: Icon(isLight ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: AppTheme.primary, size: 22),
                title: Text(isEn ? 'Light theme' : 'Tema claro',
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
                subtitle: Text(
                    isLight
                        ? (isEn ? 'Light background, colors per module' : 'Fondo claro, color por módulo')
                        : (isEn ? 'Warm dark background' : 'Fondo oscuro cálido'),
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                value: isLight,
                onChanged: (v) async {
                  ref.read(themeIsLightProvider.notifier).state = v;
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('theme_light', v);
                },
              );
            },
          ),
          Divider(color: AppTheme.border, height: 1),
          // Historial de sesiones (movido desde Entrevista)
          Consumer(
            builder: (context, ref, _) {
              final isEn = ref.watch(localeProvider).languageCode == 'en';
              return ListTile(
                leading: Icon(Icons.history_rounded, color: TabTheme.speaking.accent, size: 22),
                title: Text(isEn ? 'Session history' : 'Historial de sesiones', style: TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
                subtitle: Text(isEn ? 'Your practice and recent progress' : 'Tus prácticas y progreso reciente', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
                onTap: () => context.push('/stats'),
              );
            },
          ),
          Divider(color: AppTheme.border, height: 1),
          // Audio Settings
          ListTile(
            leading: const Icon(Icons.volume_up_rounded, color: AppTheme.primary, size: 22),
            title: Text(context.l10n.profileAudioEngine, style: TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
            subtitle: Text(context.l10n.profileAudioEngineSub, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.profileAudioSnack),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),

          // Sync NAS settings
          ListTile(
            leading: Icon(Icons.dns_rounded, color: TabTheme.vocabulary.accent, size: 22),
            title: Text(context.l10n.profileNasSync, style: TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
            subtitle: Text(context.l10n.profileNasSyncSub, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
            onTap: () => _showServerConfig(context),
          ),

          // Tutorial de la app
          ListTile(
            leading: Icon(Icons.school_rounded, color: TabTheme.speaking.accent, size: 22),
            title: Text('Tutorial de la app', style: TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
            subtitle: Text('Ver de nuevo las guías interactivas de cada sección', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
            onTap: () async {
              final cache = ref.read(localCacheProvider);
              await cache.resetAllCoaches();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tutoriales reactivados en todas las secciones.'),
                    backgroundColor: AppTheme.accent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),

          // Export options
          ListTile(
            leading: Icon(Icons.file_download_rounded, color: TabTheme.grammar.accent, size: 22),
            title: Text(context.l10n.profileExportTitle, style: TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
            subtitle: Text(context.l10n.profileExportSub, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.profileExportSnack),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),

          // Edit Profile & AI Goal
          ListTile(
            leading: Icon(Icons.psychology_alt_rounded, color: TabTheme.profile.accent, size: 22),
            title: Text('Objetivo de IA & Perfil', style: TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
            subtitle: Text('${summary.profile.roleTitle} • ${_formatLearningGoal(summary.profile.learningGoal)}', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
            onTap: () {
              Navigator.pop(context);
              _showEditProfileDialog(context, summary.profile);
            },
          ),
          Divider(color: AppTheme.border, height: 1),

          // PIN de Seguridad
          ListTile(
            leading: Icon(Icons.lock_outline_rounded, color: TabTheme.profile.accent, size: 22),
            title: Text('PIN de Seguridad', style: TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
            subtitle: Text('Establece o cambia el PIN de acceso a tu perfil', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
            onTap: () {
              Navigator.pop(context);
              _showChangePinDialog(context, summary.profile.id, summary.profile.displayName);
            },
          ),
          Divider(color: AppTheme.border, height: 1),

          // Switch user option
          ListTile(
            leading: const Icon(Icons.manage_accounts_rounded, color: AppTheme.primaryLight, size: 22),
            title: Text(context.l10n.profileManageUsers, style: TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
            subtitle: Text(context.l10n.profileActiveUser(summary.profile.displayName), style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
            onTap: () async {
              final users = await ref.read(profileRepositoryProvider).listUsers();
              if (context.mounted) {
                _showUserSwitchModal(context, users, summary.profile.id);
              }
            },
          ),
          Divider(color: AppTheme.border, height: 1),

          // Fresh Start / Reset to Zero
          ListTile(
            leading: const Icon(Icons.restart_alt_rounded, color: AppTheme.error, size: 22),
            title: const Text('Reiniciar Progreso a Cero', style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text('Borra estadísticas simuladas y empieza de cero', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.error),
            onTap: () {
              _showResetConfirmationDialog(context);
            },
          ),
          Divider(color: AppTheme.border, height: 1),

          // Privacy & Cache
          ListTile(
            leading: Icon(Icons.security_rounded, color: AppTheme.textSecondary, size: 22),
            title: Text(context.l10n.profilePrivacyTitle, style: TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
            subtitle: Text(context.l10n.profilePrivacySub, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.profilePrivacySnack),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HeatmapLegendBox extends StatelessWidget {
  final Color color;
  const _HeatmapLegendBox({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}


