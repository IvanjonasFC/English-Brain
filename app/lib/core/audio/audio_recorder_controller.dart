import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../services/client_logger.dart';

import 'dart:io' show Platform;

enum RecordingState {
  idle,
  recording,
  uploading,
  feedback,
  error,
}

class AudioRecorderController extends ChangeNotifier {
  final AudioRecorder? _recorder;
  StreamSubscription<Amplitude>? _amplitudeSub;

  AudioRecorderController({AudioRecorder? recorder})
      : _recorder = recorder ?? _createDefaultRecorder();

  static AudioRecorder? _createDefaultRecorder() {
    try {
      if (Platform.environment.containsKey('FLUTTER_TEST')) {
        return null;
      }
    } catch (_) {}
    return AudioRecorder();
  }

  RecordingState _state = RecordingState.idle;
  RecordingState get state => _state;

  double _amplitudeDb = -60.0;
  double get amplitudeDb => _amplitudeDb;

  // Normalized 0.0 to 1.0 amplitude for UI pulse/glow
  double get normalizedAmplitude {
    if (_amplitudeDb < -60) return 0.0;
    if (_amplitudeDb > 0) return 1.0;
    return (_amplitudeDb + 60) / 60.0;
  }

  String? _lastRecordingPath;
  String? get lastRecordingPath => _lastRecordingPath;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> requestPermission() async {
    return await _recorder?.hasPermission() ?? false;
  }

  Future<void> startRecording() async {
    try {
      if (_recorder == null) {
        _state = RecordingState.recording;
        _errorMessage = null;
        notifyListeners();
        return;
      }
      final hasPerm = await _recorder.hasPermission();
      if (!hasPerm) {
        _state = RecordingState.error;
        _errorMessage = 'Permiso de micrófono no concedido.';
        ClientLogger.event('recording', 'mic permission denied');
        notifyListeners();
        return;
      }

      final RecordConfig config;
      String filePath = '';

      if (kIsWeb) {
        config = const RecordConfig(
          encoder: AudioEncoder.opus,
          bitRate: 48000,
          sampleRate: 48000,
          numChannels: 1,
          autoGain: true,
          echoCancel: true,
          noiseSuppress: true,
        );
        await _recorder.start(config, path: '');
      } else {
        final tempDir = await getTemporaryDirectory();
        filePath = '${tempDir.path}/interview_answer_${DateTime.now().millisecondsSinceEpoch}.m4a';

        config = const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 64000,
          sampleRate: 44100,
          numChannels: 1,
          autoGain: true,
          echoCancel: true,
          noiseSuppress: true,
        );
        await _recorder.start(config, path: filePath);
      }

      _amplitudeSub?.cancel();
      _amplitudeSub = _recorder
          .onAmplitudeChanged(const Duration(milliseconds: 80))
          .listen((amp) {
        _amplitudeDb = amp.current;
        notifyListeners();
      });

      _state = RecordingState.recording;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _state = RecordingState.error;
      _errorMessage = 'No se pudo iniciar la grabación: $e';
      ClientLogger.error('recording', e);
      notifyListeners();
    }
  }

  Future<String?> stopRecording() async {
    if (_state != RecordingState.recording) return null;
    try {
      await _amplitudeSub?.cancel();
      _amplitudeSub = null;
      _amplitudeDb = -60.0;

      final path = await _recorder?.stop();
      _lastRecordingPath = path;
      _state = RecordingState.uploading;
      notifyListeners();
      return path;
    } catch (e) {
      _state = RecordingState.error;
      _errorMessage = 'Error al detener la grabación: $e';
      ClientLogger.error('recording', e);
      notifyListeners();
      return null;
    }
  }

  void setFeedbackState() {
    _state = RecordingState.feedback;
    notifyListeners();
  }

  void resetToIdle() {
    _state = RecordingState.idle;
    _errorMessage = null;
    notifyListeners();
  }

  void setError(String message) {
    _state = RecordingState.error;
    _errorMessage = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _amplitudeSub?.cancel();
    _recorder?.dispose();
    super.dispose();
  }
}
