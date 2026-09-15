import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import '../theme/app_theme.dart';

enum UpdateToastType { success, info, downloading }

class UpdateToastMessage {
  final String title;
  final String subtitle;
  final UpdateToastType type;
  final int durationSeconds;

  const UpdateToastMessage({
    required this.title,
    required this.subtitle,
    this.type = UpdateToastType.success,
    this.durationSeconds = 5,
  });
}

class UpdateNotificationNotifier extends StateNotifier<UpdateToastMessage?> {
  UpdateNotificationNotifier() : super(null);

  Timer? _dismissTimer;

  void show(UpdateToastMessage msg) {
    _dismissTimer?.cancel();
    state = msg;
    _dismissTimer = Timer(Duration(seconds: msg.durationSeconds), () {
      dismiss();
    });
  }

  void dismiss() {
    _dismissTimer?.cancel();
    state = null;
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }
}

final updateNotificationProvider =
    StateNotifierProvider<UpdateNotificationNotifier, UpdateToastMessage?>((ref) {
  return UpdateNotificationNotifier();
});

class ShorebirdUpdateService {
  final ShorebirdUpdater _updater = ShorebirdUpdater();
  final Ref _ref;

  ShorebirdUpdateService(this._ref);

  Future<void> initializeAndCheck() async {
    // Si estamos en entorno sin Shorebird (debug, web, tests), salimos sin error
    if (kDebugMode || !_updater.isAvailable) {
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final currentPatch = await _updater.readCurrentPatch();

      // 1. Notificar si acabamos de iniciar con un parche nuevo recién aplicado
      if (currentPatch != null) {
        final lastNotifiedPatch = prefs.getInt('shorebird_last_notified_patch') ?? -1;
        if (lastNotifiedPatch != currentPatch.number) {
          await prefs.setInt('shorebird_last_notified_patch', currentPatch.number);
          _ref.read(updateNotificationProvider.notifier).show(
                UpdateToastMessage(
                  title: '¡App Actualizada!',
                  subtitle: 'Parche #${currentPatch.number} activo con las últimas mejoras.',
                  type: UpdateToastType.success,
                  durationSeconds: 5,
                ),
              );
        }
      }

      // 2. Comprobación en segundo plano de nuevos parches disponibles
      final status = await _updater.checkForUpdate();
      if (status == UpdateStatus.outdated) {
        _ref.read(updateNotificationProvider.notifier).show(
              const UpdateToastMessage(
                title: 'Actualización Detectada',
                subtitle: 'Descargando mejoras silenciosamente en segundo plano...',
                type: UpdateToastType.downloading,
                durationSeconds: 4,
              ),
            );

        await _updater.update();

        _ref.read(updateNotificationProvider.notifier).show(
              const UpdateToastMessage(
                title: '🚀 Actualización Descargada',
                subtitle: 'Se aplicará automáticamente la próxima vez que abras la app.',
                type: UpdateToastType.info,
                durationSeconds: 6,
              ),
            );
      } else if (status == UpdateStatus.restartRequired) {
        _ref.read(updateNotificationProvider.notifier).show(
              const UpdateToastMessage(
                title: '🚀 Actualización Lista',
                subtitle: 'Reinicia la app cuando desees para activar el nuevo parche.',
                type: UpdateToastType.info,
                durationSeconds: 6,
              ),
            );
      }
    } catch (_) {
      // Proceso silencioso, no bloquea nunca la experiencia del usuario
    }
  }
}

final shorebirdUpdateServiceProvider = Provider<ShorebirdUpdateService>((ref) {
  return ShorebirdUpdateService(ref);
});

/// Widget Overlay que envuelve la app y muestra la notificación flotante adaptada
class UpdateNotificationHost extends ConsumerWidget {
  final Widget child;

  const UpdateNotificationHost({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = ref.watch(updateNotificationProvider);

    return Stack(
      children: [
        child,
        if (message != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _AnimatedUpdateToast(
                  message: message,
                  onDismiss: () =>
                      ref.read(updateNotificationProvider.notifier).dismiss(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AnimatedUpdateToast extends StatefulWidget {
  final UpdateToastMessage message;
  final VoidCallback onDismiss;

  const _AnimatedUpdateToast({
    required this.message,
    required this.onDismiss,
  });

  @override
  State<_AnimatedUpdateToast> createState() => _AnimatedUpdateToastState();
}

class _AnimatedUpdateToastState extends State<_AnimatedUpdateToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _slideAnimation = Tween<double>(begin: -30.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = AppTheme.isLight;
    final isSuccess = widget.message.type == UpdateToastType.success;
    final isDownloading = widget.message.type == UpdateToastType.downloading;

    final Color accentColor = isSuccess
        ? const Color(0xFF10B981) // Esmeralda / Éxito
        : (isDownloading ? const Color(0xFF3B82F6) : const Color(0xFF8B5CF6));

    final IconData icon = isSuccess
        ? Icons.auto_awesome_rounded
        : (isDownloading ? Icons.cloud_download_rounded : Icons.info_rounded);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: widget.onDismiss,
          onVerticalDragUpdate: (details) {
            if (details.primaryDelta != null && details.primaryDelta! < -5) {
              widget.onDismiss();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isLight
                  ? Colors.white.withValues(alpha: 0.96)
                  : const Color(0xFF1E293B).withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.4),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: accentColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.message.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isLight
                                  ? const Color(0xFF0F172A)
                                  : Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'OTA',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.message.subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isLight
                              ? const Color(0xFF475569)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: widget.onDismiss,
                  borderRadius: BorderRadius.circular(999),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: isLight
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
