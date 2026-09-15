import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/api_models.dart';

class LocalCacheService {
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // Server Base URL
  Future<void> saveBaseUrl(String url) async {
    final p = await _prefs;
    await p.setString(AppConstants.keyBaseUrl, url);
  }

  Future<String> getBaseUrl() async {
    final p = await _prefs;
    final url = p.getString(AppConstants.keyBaseUrl);
    if (url != null && url.isNotEmpty) {
      // Migrar instalaciones antiguas (LAN / localhost / puerto 8000) al dominio
      // publico. NO se toca el dominio publico ni una URL personalizada.
      if (url.contains(':8000') ||
          url.contains('192.168.0.200') ||
          url.contains('localhost') ||
          url.contains('127.0.0.1')) {
        final migrated = AppConstants.defaultBaseUrl;
        await p.setString(AppConstants.keyBaseUrl, migrated);
        return migrated;
      }
      return url;
    }
    return AppConstants.defaultBaseUrl;
  }

  // Questions Offline Cache
  Future<void> cacheQuestions(List<QuestionOut> questions) async {
    final p = await _prefs;
    final jsonList = questions.map((q) => q.toJson()).toList();
    await p.setString(AppConstants.keyCachedQuestions, jsonEncode(jsonList));
  }

  Future<List<QuestionOut>> getCachedQuestions() async {
    final p = await _prefs;
    final str = p.getString(AppConstants.keyCachedQuestions);
    if (str == null || str.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(str);
      return decoded.map((e) => QuestionOut.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // Flashcards Offline Cache
  Future<void> cacheCards(List<CardOut> cards) async {
    try {
      final p = await _prefs;
      final jsonList = cards.map((c) => c.toJson()).toList();
      await p.setString(AppConstants.keyCachedCards, jsonEncode(jsonList));
    } catch (_) {}
  }


  Future<List<CardOut>> getCachedCards() async {
    final p = await _prefs;
    final str = p.getString(AppConstants.keyCachedCards);
    if (str == null || str.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(str);
      return decoded.map((e) => CardOut.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // Content packs offline cache (cache-first). Stores the raw JSON list exactly
  // as returned by the backend / bundled asset, so it round-trips through the
  // same fromJson the providers already use.
  Future<void> saveContentList(String key, List<dynamic> raw) async {
    try {
      final p = await _prefs;
      await p.setString(key, jsonEncode(raw));
    } catch (_) {}
  }

  Future<List<dynamic>> getContentList(String key) async {
    try {
      final p = await _prefs;
      final str = p.getString(key);
      if (str == null || str.isEmpty) return const [];
      final decoded = jsonDecode(str);
      return decoded is List ? decoded : const [];
    } catch (_) {
      return const [];
    }
  }

  // Onboarding Status
  Future<bool> hasCompletedOnboarding() async {
    final p = await _prefs;
    return p.getBool('onboarding_completed') ?? false;
  }

  Future<void> setOnboardingCompleted() async {
    final p = await _prefs;
    await p.setBool('onboarding_completed', true);
  }

  // Coach-marks (per-screen tutorial overlay) seen status.
  Future<bool> hasSeenCoach(String screen) async {
    final p = await _prefs;
    return p.getBool('coach_seen_$screen') ?? false;
  }

  Future<void> markCoachSeen(String screen) async {
    final p = await _prefs;
    await p.setBool('coach_seen_$screen', true);
  }

  Future<void> resetCoaches(List<String> screens) async {
    final p = await _prefs;
    for (final s in screens) {
      await p.remove('coach_seen_$s');
    }
  }

  Future<void> resetAllCoaches() async {
    final p = await _prefs;
    final keys = p.getKeys().where((k) => k.startsWith('coach_seen_')).toList();
    for (final k in keys) {
      await p.remove(k);
    }
    const screens = ['vocabulary', 'grammar', 'comprehension', 'interview', 'home', 'profile'];
    for (final s in screens) {
      await p.remove('coach_seen_$s');
    }
  }
}

