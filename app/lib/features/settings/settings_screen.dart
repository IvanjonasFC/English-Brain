import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/extensions/l10n_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/app_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _urlController = TextEditingController();
  final _keyController = TextEditingController();

  bool _isTesting = false;
  Map<String, dynamic>? _diagnosticData;
  String? _testError;
  int _pendingOfflineCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final cache = ref.read(localCacheProvider);
    final secure = ref.read(secureStorageProvider);
    final queue = ref.read(offlineQueueProvider);

    final url = await cache.getBaseUrl();
    final key = await secure.getApiKey() ?? '';
    final pending = await queue.getPendingQueue();

    setState(() {
      _urlController.text = url;
      _keyController.text = key;
      _pendingOfflineCount = pending.length;
    });
  }

  void _applyPreset(String url) {
    setState(() {
      _urlController.text = url;
      _diagnosticData = null;
      _testError = null;
    });
    _saveSettings(silent: true);
  }

  Future<void> _saveSettings({bool silent = false}) async {
    final cache = ref.read(localCacheProvider);
    final secure = ref.read(secureStorageProvider);

    await cache.saveBaseUrl(_urlController.text.trim());
    if (_keyController.text.trim().isNotEmpty) {
      await secure.saveApiKey(_keyController.text.trim());
    }

    if (!silent && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.settingsSaved),
          backgroundColor: AppTheme.accent,
        ),
      );
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _diagnosticData = null;
      _testError = null;
    });

    await _saveSettings(silent: true);
    final api = ref.read(apiClientProvider);

    try {
      final diag = await api.checkHealthDetailed();
      setState(() {
        _isTesting = false;
        _diagnosticData = diag;
      });
    } catch (e) {
      setState(() {
        _isTesting = false;
        _testError = e.toString();
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(context.l10n.profileLogout, style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          context.l10n.settingsLogoutConfirmBody,
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n.actionCancel, style: TextStyle(color: AppTheme.textSecondary)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.error),
            child: Text(context.l10n.profileLogout, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final secure = ref.read(secureStorageProvider);
      await secure.clearAuth();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  Future<void> _syncOfflineQueue() async {
    setState(() => _isTesting = true);
    final sync = ref.read(syncServiceProvider);
    final res = await sync.syncAll();
    final queue = ref.read(offlineQueueProvider);
    final pending = await queue.getPendingQueue();

    setState(() {
      _isTesting = false;
      _pendingOfflineCount = pending.length;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message ?? 'Sincronización finalizada. Quedan ${pending.length} pendientes.'),
          backgroundColor: res.success ? AppTheme.accent : AppTheme.warning,
        ),
      );
    }
  }

  Future<void> _resetTutorial() async {
    final cache = ref.read(localCacheProvider);
    await cache.resetAllCoaches();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tutoriales reactivados en todas las pantallas. Se mostrarán al volver a entrar en cada sección.'),
          backgroundColor: AppTheme.accent,
        ),
      );
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(context.l10n.settingsTitleDiag),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Accesibilidad: Tamaño del texto y contenido
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.format_size_rounded, color: AppTheme.primary, size: 22),
                      const SizedBox(width: 8),
                      const Text('Tamaño del texto y contenido', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ajusta la escala visual de toda la aplicación para adaptarla a tu lectura.',
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  Consumer(
                    builder: (context, ref, _) {
                      final currentScale = ref.watch(textScaleFactorProvider);
                      return Row(
                        children: [
                          _scaleOption(ref, 'Compacto', 0.90, currentScale),
                          const SizedBox(width: 8),
                          _scaleOption(ref, 'Normal', 1.0, currentScale),
                          const SizedBox(width: 8),
                          _scaleOption(ref, 'Grande', 1.15, currentScale),
                          const SizedBox(width: 8),
                          _scaleOption(ref, 'Muy grande', 1.25, currentScale),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Connection & Presets Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.l10n.settingsServerConn, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    context.l10n.settingsPresetHelp,
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 14),

                  // Presets Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.laptop_chromebook_rounded, size: 16, color: AppTheme.primary),
                        label: Text(context.l10n.connLocalPc, style: const TextStyle(fontSize: 12)),
                        backgroundColor: AppTheme.surfaceLight,
                        side: BorderSide(color: AppTheme.border),
                        onPressed: () => _applyPreset('http://localhost:8092'),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.home_rounded, size: 16, color: AppTheme.secondary),
                        label: Text(context.l10n.connLanHome, style: const TextStyle(fontSize: 12)),
                        backgroundColor: AppTheme.surfaceLight,
                        side: BorderSide(color: AppTheme.border),
                        onPressed: () => _applyPreset('http://192.168.0.200:8092'),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.vpn_key_rounded, size: 16, color: AppTheme.secondary),
                        label: Text(context.l10n.connWireguard, style: const TextStyle(fontSize: 12)),
                        backgroundColor: AppTheme.surfaceLight,
                        side: BorderSide(color: AppTheme.border),
                        onPressed: () => _applyPreset('http://192.168.0.200:8092'),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.lock_outline_rounded, size: 16, color: AppTheme.success),
                        label: Text(context.l10n.connHttpsCaddy, style: const TextStyle(fontSize: 12)),
                        backgroundColor: AppTheme.surfaceLight,
                        side: BorderSide(color: AppTheme.border),
                        onPressed: () => _applyPreset('https://ingles.ivanjonasfc.dev'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      labelText: context.l10n.settingsServerAddr,
                      prefixIcon: const Icon(Icons.dns_rounded, color: AppTheme.primary),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _keyController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: context.l10n.settingsApiKeyAuth,
                      prefixIcon: const Icon(Icons.key_rounded, color: AppTheme.primary),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.save_rounded, size: 18),
                          label: Text(context.l10n.actionSave),
                          onPressed: () => _saveSettings(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          icon: _isTesting
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                              : const Icon(Icons.network_ping_rounded, size: 18),
                          label: Text(context.l10n.settingsDiagnostics),
                          onPressed: _isTesting ? null : _testConnection,
                        ),
                      ),
                    ],
                  ),

                  // Diagnostic Results
                  if (_diagnosticData != null) ...[
                    const SizedBox(height: 16),
                    _buildDiagnosticReport(_diagnosticData!),
                  ],

                  if (_testError != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: AppTheme.error, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _testError!,
                              style: const TextStyle(color: AppTheme.error, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Offline Queue Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(context.l10n.settingsOfflineQueue, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: _pendingOfflineCount > 0 ? AppTheme.warning.withValues(alpha: 0.2) : AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$_pendingOfflineCount pendientes',
                          style: TextStyle(
                            color: _pendingOfflineCount > 0 ? AppTheme.warning : AppTheme.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.settingsOfflineQueueHelp,
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.sync_rounded, size: 18),
                      label: Text(context.l10n.settingsForceSync),
                      onPressed: _pendingOfflineCount > 0 ? _syncOfflineQueue : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Session & Logout Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tutorial de la app', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    'Vuelve a ver las guías superpuestas que explican cada pantalla y sus opciones.',
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.school_rounded, size: 18, color: AppTheme.primary),
                      label: const Text('Ver tutorial de nuevo', style: TextStyle(color: AppTheme.primary)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.4)),
                      ),
                      onPressed: _resetTutorial,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.l10n.settingsSessionSecurity, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.settingsSessionHelp,
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout_rounded, size: 18, color: AppTheme.error),
                      label: Text(context.l10n.profileLogout, style: const TextStyle(color: AppTheme.error)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.error.withValues(alpha: 0.4)),
                      ),
                      onPressed: _handleLogout,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticReport(Map<String, dynamic> data) {
    final latency = data['latency_ms'] ?? 0;
    final version = data['version'] ?? '1.0.0';
    final status = data['status'] ?? 'ok';
    final services = data['services'] as Map<String, dynamic>? ?? {};

    final ollama = services['ollama'] as Map<String, dynamic>? ?? {};
    final speaches = services['speaches'] as Map<String, dynamic>? ?? {};

    final ollamaStatus = ollama['status'] ?? 'unknown';
    final speachesStatus = speaches['status'] ?? 'unknown';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 18),
              const SizedBox(width: 8),
              Text(
                'Servidor Operativo ($status, v$version)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
              ),
              const Spacer(),
              Text(
                '${latency}ms',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primary),
              ),
            ],
          ),
          Divider(height: 18, color: AppTheme.border),
          _buildServiceRow('Ollama LLM (Qwen 2.5)', ollamaStatus),
          const SizedBox(height: 6),
          _buildServiceRow('Speaches (Whisper STT / Piper TTS)', speachesStatus),
        ],
      ),
    );
  }

  Widget _buildServiceRow(String name, String status) {
    final isOnline = status == 'online';
    return Row(
      children: [
        Icon(
          isOnline ? Icons.circle : Icons.circle_outlined,
          size: 10,
          color: isOnline ? AppTheme.success : AppTheme.warning,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            name,
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ),
        Text(
          isOnline ? 'Online' : status,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isOnline ? AppTheme.success : AppTheme.warning,
          ),
        ),
      ],
    );
  }

  Widget _scaleOption(WidgetRef ref, String label, double scale, double currentScale) {
    final isSelected = (currentScale - scale).abs() < 0.02;
    return Expanded(
      child: InkWell(
        onTap: () async {
          HapticFeedback.lightImpact();
          ref.read(textScaleFactorProvider.notifier).state = scale;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setDouble('content_scale', scale);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary.withValues(alpha: 0.15) : AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primary : AppTheme.border,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'A',
                style: TextStyle(
                  fontSize: 14 * scale,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
