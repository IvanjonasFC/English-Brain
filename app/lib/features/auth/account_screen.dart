import 'dart:async';
import 'package:flutter/material.dart';
import 'placement_test_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/app_providers.dart';
import '../../core/database/app_database.dart';
import '../../core/constants/app_constants.dart';

/// Pantalla de inicio: elige o crea una cuenta local (nombre + PIN, offline).
/// Siempre solicita el PIN de seguridad al pulsar sobre cualquier perfil.
/// Muestra el icono oficial de la app y la información completa y actualizada
/// de cada usuario (Avatar, Nivel, Rol, XP real y Racha).
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  Future<List<UserProfilesLocalData>>? _usersFuture;
  Set<String> _pinnedUserIds = {};
  bool _busy = false;
  String? _activatingUserId;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _usersFuture = ref.read(profileRepositoryProvider).listUsers().then((users) async {
        final secure = ref.read(secureStorageProvider);
        final pinned = <String>{};
        for (final u in users) {
          if (await secure.hasPin(u.id)) {
            pinned.add(u.id);
          }
        }
        if (mounted) {
          setState(() => _pinnedUserIds = pinned);
        }
        return users;
      });
    });
  }

  Future<void> _activate(String userId) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _activatingUserId = userId;
    });
    try {
      final secure = ref.read(secureStorageProvider);
      final cache = ref.read(localCacheProvider);

      final url = await cache.getBaseUrl();
      if (url.isEmpty) {
        await cache.saveBaseUrl(AppConstants.defaultBaseUrl);
      }
      if (((await secure.getApiKey()) ?? '').isEmpty) {
        await secure.saveApiKey(AppConstants.defaultApiKey);
      }
      await ref.read(profileRepositoryProvider).switchUser(userId);
      ref.read(activeUserIdProvider.notifier).state = userId;
      await secure.saveActiveUserId(userId);

      // Sincronización en segundo plano con el backend si está disponible (no bloquea)
      unawaited(ref.read(apiClientProvider).reauthenticateAs(userId).catchError((_) {}));
      if (mounted) context.go('/');
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _activatingUserId = null;
        });
      }
    }
  }

  /// Al pulsar sobre una cuenta: SIEMPRE salta el PIN de acceso.
  /// - Si ya tiene PIN: solicita el PIN de 4 dígitos.
  /// - Si aún no tiene PIN configurado: solicita establecer el PIN de 4 dígitos para esa cuenta.
  Future<void> _onTapAccount(UserProfilesLocalData u) async {
    final secure = ref.read(secureStorageProvider);
    final hasPin = await secure.hasPin(u.id);

    if (!mounted) return;

    if (!hasPin) {
      // Salta el PIN para crearlo y dejar la cuenta protegida
      String? newPin;
      final ok = await _promptPin(
        title: 'Crea tu PIN de acceso',
        subtitle: 'Configura un PIN de 4 dígitos para acceder a la cuenta de ${u.displayName}',
        validate: (pin) async {
          newPin = pin;
          return true;
        },
        confirm: true,
      );

      if (ok == true && newPin != null && newPin!.isNotEmpty) {
        await secure.savePin(u.id, newPin!);
        unawaited(ref.read(apiClientProvider).setUserPin(u.id, newPin!).catchError((_) => false));
        _reload();
        await _activate(u.id);
      }
      return;
    }

    // Salta el PIN para acceder a la cuenta
    final expectedPin = await secure.getPin(u.id);
    final ok = await _promptPin(
      title: 'Introduce tu PIN',
      subtitle: 'Acceso a la cuenta de ${u.displayName}',
      validate: (pin) async {
        if (expectedPin != null && expectedPin.isNotEmpty) {
          return pin == expectedPin;
        }
        // Si no está en el teléfono (instalación limpia), verificar con el servidor:
        final api = ref.read(apiClientProvider);
        final verified = await api.verifyUserPin(u.id, pin);
        if (verified) {
          await secure.savePin(u.id, pin);
          return true;
        }
        return false;
      },
      onResetPin: () async {
        // Opción de reestablecer el PIN
        String? resetPin;
        final resetOk = await _promptPin(
          title: 'Reestablecer PIN',
          subtitle: 'Introduce un nuevo PIN de 4 dígitos para ${u.displayName}',
          validate: (pin) async {
            resetPin = pin;
            return true;
          },
          confirm: true,
        );
        if (resetOk == true && resetPin != null && resetPin!.isNotEmpty) {
          await secure.savePin(u.id, resetPin!);
          unawaited(ref.read(apiClientProvider).setUserPin(u.id, resetPin!).catchError((_) => false));
          _reload();
          await _activate(u.id);
        }
      },
    );

    if (ok == true) {
      await _activate(u.id);
    }
  }

  Future<void> _createAccountFlow() async {
    final nameCtrl = TextEditingController();
    String goal = 'interview_prep';
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheet) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: AppTheme.textSecondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text('Crear cuenta',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                Text('Tu progreso se guarda solo, aislado por cuenta.',
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                const SizedBox(height: 20),
                TextField(
                  controller: nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.person_rounded, color: AppTheme.primary),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: goal,
                  isExpanded: true,
                  dropdownColor: AppTheme.surfaceLight,
                  style: TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Objetivo de Aprendizaje (Foco IA)',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    prefixIcon: const Icon(Icons.flag_rounded, color: AppTheme.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'interview_prep', child: Text('Entrevistas y Fluidez General (Todo en uno)')),
                    DropdownMenuItem(value: 'interviews', child: Text('Preparacion para Entrevistas de Trabajo')),
                    DropdownMenuItem(value: 'general_fluency', child: Text('Conversacion y Fluidez del Dia a Dia')),
                    DropdownMenuItem(value: 'daily_meetings', child: Text('Reuniones de Trabajo y Comunicacion')),
                    DropdownMenuItem(value: 'technical_career', child: Text('Ingles Tecnico y Profesional')),
                  ],
                  onChanged: (val) {
                    if (val != null) setSheet(() => goal = val);
                  },
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Continuar'),
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty) return;
                    Navigator.pop(ctx, true);
                  },
                ),
              ],
            ),
          );
        });
      },
    );

    if (created != true) return;
    final name = nameCtrl.text.trim();
    if (name.isEmpty) return;

    // Pedir PIN nuevo (con confirmación)
    if (!mounted) return;
    String? firstPin;
    final ok = await _promptPin(
      title: 'Crea un PIN',
      subtitle: 'Para $name (4 dígitos)',
      validate: (pin) async {
        firstPin = pin;
        return true;
      },
      confirm: true,
    );
    if (ok != true || firstPin == null) return;

    setState(() => _busy = true);
    try {
      final profile = await ref.read(profileRepositoryProvider).createUser(displayName: name, learningGoal: goal);
      await ref.read(secureStorageProvider).savePin(profile.id, firstPin!);
      unawaited(ref.read(apiClientProvider).setUserPin(profile.id, firstPin!).catchError((_) => false));
      if (mounted) setState(() => _busy = false);
      // Test inicial de nivel (opcional) -> ajusta target_level
      if (mounted) {
        final level = await Navigator.of(context).push<String>(
          MaterialPageRoute(
            builder: (_) => PlacementTestScreen(displayName: name),
          ),
        );
        if (level != null && level.isNotEmpty) {
          await ref
              .read(profileRepositoryProvider)
              .updateUserProfile(userId: profile.id, targetLevel: level);
        }
      }
      _reload();
      await _activate(profile.id);
    } catch (_) {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Diálogo estilizado de PIN para autenticación o configuración
  Future<bool?> _promptPin({
    required String title,
    required String subtitle,
    required Future<bool> Function(String pin) validate,
    bool confirm = false,
    Future<void> Function()? onResetPin,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final ctrl = TextEditingController();
        final ctrl2 = TextEditingController();
        String? error;
        bool validating = false;

        return StatefulBuilder(
          builder: (ctx, setS) {
            InputDecoration dec(String label) => InputDecoration(
                  labelText: label,
                  counterText: '',
                  prefixIcon: const Icon(Icons.lock_rounded, color: AppTheme.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  filled: true,
                  fillColor: AppTheme.surfaceLight,
                );

            return AlertDialog(
              backgroundColor: AppTheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_rounded, color: AppTheme.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(subtitle, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  const SizedBox(height: 18),
                  TextField(
                    controller: ctrl,
                    autofocus: true,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      letterSpacing: 12,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: dec('PIN (4 dígitos)'),
                  ),
                  if (confirm) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: ctrl2,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        letterSpacing: 12,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: dec('Repite el PIN'),
                    ),
                  ],
                  if (error != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: AppTheme.error, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              error!,
                              style: const TextStyle(color: AppTheme.error, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (onResetPin != null && !confirm) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () async {
                          Navigator.pop(ctx, false);
                          await onResetPin();
                        },
                        child: const Text(
                          '¿Olvidaste tu PIN?',
                          style: TextStyle(color: AppTheme.primary, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text('Cancelar', style: TextStyle(color: AppTheme.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  onPressed: validating
                      ? null
                      : () async {
                          final pin = ctrl.text.trim();
                          if (pin.length < 4) {
                            setS(() => error = 'El PIN debe tener al menos 4 dígitos');
                            return;
                          }
                          if (confirm && pin != ctrl2.text.trim()) {
                            setS(() => error = 'Los PIN no coinciden');
                            return;
                          }
                          setS(() {
                            validating = true;
                            error = null;
                          });
                          final okv = await validate(pin);
                          if (okv) {
                            if (ctx.mounted) Navigator.pop(ctx, true);
                          } else {
                            setS(() {
                              validating = false;
                              error = 'PIN incorrecto. Inténtalo de nuevo';
                            });
                          }
                        },
                  child: validating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : Text(
                          confirm ? 'Guardar PIN' : 'Entrar',
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _serverConfig() async {
    final cache = ref.read(localCacheProvider);
    final secure = ref.read(secureStorageProvider);
    final initialUrl = await cache.getBaseUrl();
    final urlCtrl = TextEditingController(text: initialUrl);
    final keyCtrl = TextEditingController(text: (await secure.getApiKey()) ?? '');

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.dns_rounded, color: AppTheme.primary, size: 22),
            const SizedBox(width: 10),
            Text('Servidor (opcional)', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Para sincronizar con tu NAS. Puedes dejarlo por defecto y usar la app en local.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 14),
            TextField(
              controller: urlCtrl,
              style: TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(labelText: 'URL', prefixIcon: Icon(Icons.dns_rounded, color: AppTheme.primary)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: keyCtrl,
              style: TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(labelText: 'API Key', prefixIcon: Icon(Icons.key_rounded, color: AppTheme.primary)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cerrar', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            onPressed: () async {
              await cache.saveBaseUrl(urlCtrl.text.trim());
              await secure.saveApiKey(keyCtrl.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
              _reload();
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              children: [
                // Icono oficial de la app (English Brain)
                Center(
                  child: Container(
                    width: 82,
                    height: 82,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                        colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(19),
                      child: Image.asset(
                        'assets/icon/icon_1024.png',
                        width: 76,
                        height: 76,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppTheme.surfaceLight,
                          child: const Icon(Icons.psychology_rounded, size: 40, color: AppTheme.primary),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'English Brain',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Elige tu cuenta para empezar',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 26),

                // Lista de perfiles con información completa y XP actualizada
                FutureBuilder<List<UserProfilesLocalData>>(
                  future: _usersFuture,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(28),
                        child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
                      );
                    }
                    final users = snap.data ?? [];
                    return Column(
                      children: [
                        ...users.map(_accountCard),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            side: BorderSide(color: AppTheme.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          icon: const Icon(Icons.add_rounded, color: AppTheme.primary),
                          label: Text('Crear cuenta nueva',
                              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                          onPressed: _busy ? null : _createAccountFlow,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton.icon(
                    icon: Icon(Icons.dns_rounded, size: 16, color: AppTheme.textSecondary),
                    label: Text('Servidor (opcional)',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    onPressed: _serverConfig,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _accountCard(UserProfilesLocalData u) {
    final initial = u.displayName.isNotEmpty ? u.displayName[0].toUpperCase() : '?';
    final isActivating = _busy && _activatingUserId == u.id;
    final hasPin = _pinnedUserIds.contains(u.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: _busy ? null : () => _onTapAccount(u),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isActivating ? AppTheme.primary : AppTheme.border,
              width: isActivating ? 1.8 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar con inicial y badge de nivel objetivo
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primary,
                          AppTheme.primary.withValues(alpha: 0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: AppTheme.primary, width: 0.8),
                    ),
                    child: Text(
                      u.targetLevel.isNotEmpty ? u.targetLevel : 'B2',
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              // Detalles del usuario con XP, Racha y Estado de PIN
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            u.displayName,
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Icono de PIN: protegido o pendiente
                        Icon(
                          hasPin ? Icons.lock_rounded : Icons.lock_outline_rounded,
                          size: 14,
                          color: hasPin ? AppTheme.primary : AppTheme.textSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 6),
                        // Badge de XP destacada
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.primary.withValues(alpha: 0.35),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.bolt_rounded, size: 12, color: AppTheme.primary),
                              const SizedBox(width: 2),
                              Text(
                                '${u.totalXp} XP',
                                style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (u.streakDays > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF97316).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.local_fire_department_rounded, size: 12, color: Color(0xFFF97316)),
                                const SizedBox(width: 2),
                                Text(
                                  '${u.streakDays}',
                                  style: const TextStyle(
                                    color: Color(0xFFF97316),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      u.roleTitle.isNotEmpty ? u.roleTitle : 'English Learner',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isActivating)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                )
              else
                Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
