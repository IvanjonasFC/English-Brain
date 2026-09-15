import 'package:flutter/material.dart';
import '../../core/extensions/l10n_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/app_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _urlController = TextEditingController();
  final _keyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscureKey = true;
  bool _isLoading = false;
  bool _isTesting = false;
  String? _errorMessage;
  String? _testSuccessMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialConfig();
  }

  Future<void> _loadInitialConfig() async {
    final cache = ref.read(localCacheProvider);
    final secure = ref.read(secureStorageProvider);

    final currentUrl = await cache.getBaseUrl();
    final savedKey = await secure.getApiKey() ?? '';

    setState(() {
      _urlController.text = currentUrl;
      _keyController.text = savedKey;
    });
  }

  void _applyPreset(String url, {String? defaultKey}) {
    setState(() {
      _urlController.text = url;
      if (defaultKey != null && _keyController.text.trim().isEmpty) {
        _keyController.text = defaultKey;
      }
      _errorMessage = null;
      _testSuccessMessage = null;
    });
  }

  Future<void> _testConnection() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _errorMessage = 'Introduce primero la URL del servidor.');
      return;
    }

    setState(() {
      _isTesting = true;
      _errorMessage = null;
      _testSuccessMessage = null;
    });

    try {
      final cache = ref.read(localCacheProvider);
      await cache.saveBaseUrl(url);

      final api = ref.read(apiClientProvider);
      final health = await api.checkHealthDetailed();

      final latency = health['latency_ms'] ?? 0;
      final version = health['version'] ?? '1.0.0';
      final status = health['status'] ?? 'ok';

      if (!mounted) return;
      setState(() {
        _isTesting = false;
        _testSuccessMessage = '¡Conexión exitosa ($latency ms)! API v$version - Estado: $status';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isTesting = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final url = _urlController.text.trim();
    final apiKey = _keyController.text.trim();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cache = ref.read(localCacheProvider);
      await cache.saveBaseUrl(url);

      final api = ref.read(apiClientProvider);
      await api.login(apiKey, userId: ref.read(activeUserIdProvider));

      if (mounted) {
        setState(() => _isLoading = false);
        try {
          context.go('/');
        } catch (_) {}
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Header
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                        ),
                        child: const Icon(
                          Icons.record_voice_over_rounded,
                          size: 36,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'English Brain',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.l10n.loginTagline,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Quick Presets
                    Text(
                      context.l10n.connPresets,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.lock_outline_rounded, size: 16, color: AppTheme.success),
                          label: Text(context.l10n.connHttpsCaddy, style: const TextStyle(fontSize: 12)),
                          backgroundColor: AppTheme.surface,
                          side: BorderSide(color: AppTheme.border),
                          onPressed: () => _applyPreset('https://ingles.ivanjonasfc.dev', defaultKey: 'super-secret-key-123'),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.laptop_chromebook_rounded, size: 16, color: AppTheme.primary),
                          label: Text(context.l10n.connLocalPc, style: const TextStyle(fontSize: 12)),
                          backgroundColor: AppTheme.surface,
                          side: BorderSide(color: AppTheme.border),
                          onPressed: () => _applyPreset('http://localhost:8092', defaultKey: 'super-secret-key-123'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Server URL Input
                    TextFormField(
                      controller: _urlController,
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(
                        labelText: context.l10n.loginServerUrlLabel,
                        prefixIcon: const Icon(Icons.dns_rounded, color: AppTheme.primary),
                        hintText: 'https://ingles.ivanjonasfc.dev',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Introduce la URL del servidor';
                        }
                        if (!value.startsWith('http://') && !value.startsWith('https://')) {
                          return 'Debe comenzar con http:// o https://';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // API Key Input
                    TextFormField(
                      controller: _keyController,
                      obscureText: _obscureKey,
                      decoration: InputDecoration(
                        labelText: context.l10n.loginApiKeyLabel,
                        prefixIcon: const Icon(Icons.key_rounded, color: AppTheme.primary),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureKey ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            color: AppTheme.textSecondary,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscureKey = !_obscureKey),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Introduce la API Key configurada en tu servidor';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Connection Test Button
                    OutlinedButton.icon(
                      icon: _isTesting
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                            )
                          : const Icon(Icons.network_ping_rounded, size: 18),
                      label: Text(_isTesting ? 'Comprobando...' : 'Probar Conectividad y Diagnóstico'),
                      onPressed: (_isTesting || _isLoading) ? null : _testConnection,
                    ),

                    // Status Banners
                    if (_testSuccessMessage != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _testSuccessMessage!,
                                style: const TextStyle(color: AppTheme.success, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.error_outline_rounded, color: AppTheme.error, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: AppTheme.error, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Submit Button
                    FilledButton.icon(
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : const Icon(Icons.login_rounded, size: 20),
                      label: Text(_isLoading ? 'Autenticando...' : 'Iniciar Sesión'),
                      onPressed: (_isLoading || _isTesting) ? null : _handleLogin,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
