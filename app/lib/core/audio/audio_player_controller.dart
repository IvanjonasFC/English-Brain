import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../constants/app_constants.dart';
import '../storage/local_cache_service.dart';
import 'local_audio_cache_manager.dart';
import 'voice_selection.dart';


class AudioPlayerController extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  final LocalCacheService? _cacheService;
  String? _currentAudioSource;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  Duration _duration = Duration.zero;
  Duration get duration => _duration;

  Duration _position = Duration.zero;
  Duration get position => _position;

  AudioPlayerController({LocalCacheService? cacheService})
      : _cacheService = cacheService {
    _init();
  }

  void _init() {
    _initNativeTts();

    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing && state.processingState != ProcessingState.completed;
      if (state.processingState == ProcessingState.completed) {
        _currentlyPlayingText = null;
      }
      notifyListeners();
    });

    _player.durationStream.listen((d) {
      _duration = d ?? Duration.zero;
      notifyListeners();
    });

    _player.positionStream.listen((p) {
      _position = p;
      notifyListeners();
    });
  }

  void _initNativeTts() async {
    try {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setPitch(1.0);
      _flutterTts.setCompletionHandler(() {
        _isPlaying = false;
        _currentlyPlayingText = null;
        notifyListeners();
      });
      _flutterTts.setStartHandler(() {
        _isPlaying = true;
        notifyListeners();
      });
      _flutterTts.setErrorHandler((_) {
        _isPlaying = false;
        _currentlyPlayingText = null;
        notifyListeners();
      });
    } catch (_) {}
  }

  String? _currentlyPlayingText;
  String? get currentlyPlayingText => _currentlyPlayingText;

  Future<void> playNativeTts(String text, {bool slow = false}) async {
    try {
      await _player.stop();
      _currentlyPlayingText = text;
      _isPlaying = true;
      notifyListeners();
      await _flutterTts.setSpeechRate(slow ? 0.35 : 0.5);
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('Native TTS error: $e');
      _isPlaying = false;
      _currentlyPlayingText = null;
      notifyListeners();
    }
  }

  Future<void> playAudioUrl(String url, {String? fallbackText}) async {
    try {
      _currentAudioSource = url;
      await _flutterTts.stop();
      await _player.stop();
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      debugPrint('AudioPlayer error loading URL: $e');
      String? textToSpeak = fallbackText;
      if (textToSpeak == null || textToSpeak.isEmpty) {
        try {
          final uri = Uri.parse(url);
          textToSpeak = uri.queryParameters['text'];
        } catch (_) {}
      }

      if (textToSpeak != null && textToSpeak.isNotEmpty) {
        await playNativeTts(textToSpeak);
      } else {
        _currentlyPlayingText = null;
        _isPlaying = false;
        notifyListeners();
      }
    }
  }

  Future<void> playFilePath(String filePath) async {
    try {
      _currentAudioSource = filePath;
      await _flutterTts.stop();
      await _player.stop();
      await _player.setFilePath(filePath);
      await _player.play();
    } catch (e) {
      debugPrint('AudioPlayer error loading local file: $e');
      _currentlyPlayingText = null;
      notifyListeners();
    }
  }

  Future<void> setSpeed(double speed) async {
    try {
      await _player.setSpeed(speed);
      notifyListeners();
    } catch (e) {
      debugPrint('AudioPlayer error setting speed: $e');
    }
  }

  Future<void> playTts(

    String text, {
    bool slow = false,
    String voice = 'en-US-GuyNeural',
    String? baseUrl,
  }) async {
    if (text.trim().isEmpty) return;
    try {
      await _flutterTts.stop();
      _currentlyPlayingText = text;
      notifyListeners();

      final rate = slow ? '-20%' : '+0%';

      // Voz rotatoria estable (am_michael / Emma / Fable) salvo que se pida una concreta.
      voice = AppVoices.resolve(voice, text);

      // 1. Comprobar primero la caché LRU local en el dispositivo (0 ms de latencia / offline)
      final localPath = await LocalAudioCacheManager.instance.getCachedAudioFilePath(
        text,
        voice: voice,
        rate: rate,
      );

      if (localPath != null) {
        await playFilePath(localPath);
        return;
      }

      // 2. Si no está en la caché del dispositivo, descargar del backend y guardar en LRU
      String effectiveBase = baseUrl ?? '';
      if (effectiveBase.isEmpty && _cacheService != null) {
        effectiveBase = await _cacheService.getBaseUrl();
      }
      if (effectiveBase.isEmpty) {
        effectiveBase = AppConstants.defaultBaseUrl;
      }
      final cleanBase = effectiveBase.endsWith('/')
          ? effectiveBase.substring(0, effectiveBase.length - 1)
          : effectiveBase;
      final encodedText = Uri.encodeComponent(text);
      final rateParam = slow ? '-20' : '+0';
      final url = '$cleanBase/api/tts?text=$encodedText&voice=$voice&rate=$rateParam';

      final downloadedPath = await LocalAudioCacheManager.instance.fetchAndCacheAudio(
        url,
        text,
        voice: voice,
        rate: rate,
      );

      if (downloadedPath != null) {
        await playFilePath(downloadedPath);
      } else {
        // Fallback inmediato a síntesis nativa en dispositivo (0 lag)
        await playNativeTts(text, slow: slow);
      }
    } catch (e) {
      debugPrint('Remote playTts failed ($e), using native on-device TTS');
      await playNativeTts(text, slow: slow);
    }
  }


  Future<void> replay() async {
    try {
      if (_currentAudioSource != null) {
        await _player.seek(Duration.zero);
        await _player.play();
      } else if (_currentlyPlayingText != null) {
        await playNativeTts(_currentlyPlayingText!);
      }
    } catch (e) {
      debugPrint('AudioPlayer replay error: $e');
    }
  }

  Future<void> stop() async {
    _currentlyPlayingText = null;
    _isPlaying = false;
    try {
      await _player.stop();
      await _flutterTts.stop();
    } catch (_) {}
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    _flutterTts.stop();
    super.dispose();
  }
}

