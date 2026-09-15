import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../services/client_logger.dart';

/// Almacenamiento de credenciales/PIN con FALLBACK a SharedPreferences.
///
/// Motivo: en algunos móviles el keystore de Android falla
/// (KeyStoreException -30000 / "Failed to unwrap key"), lo que impedía
/// persistir la sesión (rebote al selector) y leer el PIN. Aquí:
///   1) Se intenta flutter_secure_storage (cifrado por keystore).
///   2) Si lanza excepción, se usa SharedPreferences (privado de la app).
/// Así la app SIEMPRE persiste, con o sin keystore funcional. Para un PIN
/// local de una app de aprendizaje self-hosted el trade-off es aceptable.
class SecureStorageService {
  static const AndroidOptions _android =
      AndroidOptions(encryptedSharedPreferences: true, resetOnError: true);
  final FlutterSecureStorage _storage =
      const FlutterSecureStorage(aOptions: _android);

  static const String _pfx = 'ss_'; // prefijo del fallback en SharedPreferences

  Future<void> _write(String key, String value) async {
    if (kIsWeb) {
      try {
        final p = await SharedPreferences.getInstance();
        await p.setString('$_pfx$key', value);
      } catch (e, s) {
        ClientLogger.error('prefs_write:$key', e, s);
      }
      return;
    }
    // Intento cifrado (donde el keystore funciona).
    try {
      await _storage.write(key: key, value: value);
    } catch (e, s) {
      ClientLogger.error('secure_write:$key', e, s);
    }
    // Y SIEMPRE en el fallback plano, para garantizar persistencia aunque el
    // keystore diga que escribió pero luego no pueda descifrar (Km -30000).
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString('$_pfx$key', value);
    } catch (e, s) {
      ClientLogger.error('prefs_write:$key', e, s);
    }
  }

  Future<String?> _read(String key) async {
    if (kIsWeb) {
      try {
        final p = await SharedPreferences.getInstance();
        return p.getString('$_pfx$key');
      } catch (e, s) {
        ClientLogger.error('prefs_read:$key', e, s);
        return null;
      }
    }
    try {
      final v = await _storage.read(key: key);
      if (v != null) return v;
    } catch (e, s) {
      ClientLogger.error('secure_read:$key', e, s);
    }
    // Fallback (o valor escrito por el fallback en un arranque anterior).
    try {
      final p = await SharedPreferences.getInstance();
      return p.getString('$_pfx$key');
    } catch (e, s) {
      ClientLogger.error('prefs_read:$key', e, s);
      return null;
    }
  }

  Future<void> _delete(String key) async {
    if (kIsWeb) {
      try {
        final p = await SharedPreferences.getInstance();
        await p.remove('$_pfx$key');
      } catch (e, s) {
        ClientLogger.error('prefs_delete:$key', e, s);
      }
      return;
    }
    try {
      await _storage.delete(key: key);
    } catch (e, s) {
      ClientLogger.error('secure_delete:$key', e, s);
    }
    try {
      final p = await SharedPreferences.getInstance();
      await p.remove('$_pfx$key');
    } catch (_) {}
  }

  Future<void> saveApiKey(String apiKey) => _write(AppConstants.keyApiKey, apiKey);
  Future<String?> getApiKey() => _read(AppConstants.keyApiKey);

  Future<void> saveToken(String token) => _write(AppConstants.keyJwtToken, token);
  Future<String?> getToken() => _read(AppConstants.keyJwtToken);

  Future<void> saveActiveUserId(String userId) => _write(AppConstants.keyActiveUserId, userId);
  Future<String?> getActiveUserId() => _read(AppConstants.keyActiveUserId);

  Future<void> savePin(String userId, String pin) async {
    await _write('pin_$userId', pin);
    await _write('server_has_pin_$userId', 'true');
  }

  Future<String?> getPin(String userId) => _read('pin_$userId');

  Future<void> setServerHasPin(String userId, bool has) =>
      _write('server_has_pin_$userId', has ? 'true' : 'false');

  Future<bool> hasPin(String userId) async {
    final p = await _read('pin_$userId');
    if (p != null && p.isNotEmpty) return true;
    final serverHas = await _read('server_has_pin_$userId');
    return serverHas == 'true';
  }

  Future<void> removePin(String userId) async {
    await _delete('pin_$userId');
    await _delete('server_has_pin_$userId');
  }

  Future<void> clearAuth() async {
    await _delete(AppConstants.keyApiKey);
    await _delete(AppConstants.keyJwtToken);
    await _delete(AppConstants.keyActiveUserId);
  }
}
