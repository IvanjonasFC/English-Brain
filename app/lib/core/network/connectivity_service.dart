import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'api_client.dart';

class ConnectivityState {
  final bool hasNetwork;
  final bool hasServerAccess;
  final int? latencyMs;
  final String? statusMessage;

  const ConnectivityState({
    required this.hasNetwork,
    required this.hasServerAccess,
    this.latencyMs,
    this.statusMessage,
  });

  bool get isReady => hasNetwork && hasServerAccess;
}

/// Connectivity service that:
/// - Listens to OS-level network changes (connectivity_plus)
/// - Pings the backend every 15 s
/// - Always replays the latest state to new subscribers (BehaviorSubject-like)
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final ApiClient _apiClient;

  // A standard broadcast controller for push-based events.
  final StreamController<ConnectivityState> _controller =
      StreamController<ConnectivityState>.broadcast();

  ConnectivityState _lastState = const ConnectivityState(
    hasNetwork: true,
    hasServerAccess: true,
    statusMessage: 'Conectando…',
  );
  ConnectivityState get currentState => _lastState;

  /// Stream that replays the last known state immediately upon subscription,
  /// followed by any subsequent changes.  This prevents the Riverpod
  /// StreamProvider from staying in AsyncLoading after widget rebuild.
  Stream<ConnectivityState> get statusStream async* {
    yield _lastState; // replay latest value to new subscriber
    yield* _controller.stream;
  }

  StreamSubscription<List<ConnectivityResult>>? _sub;
  Timer? _heartbeatTimer;

  ConnectivityService(this._apiClient) {
    _init();
  }

  void _init() {
    // React to OS-level network changes (WiFi on/off, airplane mode, etc.)
    _sub = _connectivity.onConnectivityChanged.listen((results) {
      final hasNet = !results.contains(ConnectivityResult.none);
      if (!hasNet) {
        _emit(const ConnectivityState(
          hasNetwork: false,
          hasServerAccess: false,
          statusMessage: 'Sin conexión de red en el dispositivo',
        ));
      } else {
        // Network restored → probe backend immediately
        checkServerReachability();
      }
    });

    // Startup probe + heartbeat every 15 s
    checkServerReachability();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      checkServerReachability();
    });
  }

  Future<ConnectivityState> checkServerReachability() async {
    try {
      final latency = await _apiClient.checkHealth();
      final state = ConnectivityState(
        hasNetwork: true,
        hasServerAccess: true,
        latencyMs: latency,
        statusMessage: 'Conectado con el NAS (${latency}ms)',
      );
      _emit(state);
      return state;
    } catch (e) {
      final state = ConnectivityState(
        hasNetwork: true,
        hasServerAccess: false,
        statusMessage: 'Sin acceso al NAS: ${e.toString()}',
      );
      _emit(state);
      return state;
    }
  }

  void _emit(ConnectivityState state) {
    _lastState = state;
    if (!_controller.isClosed) {
      _controller.add(state);
    }
  }

  void dispose() {
    _sub?.cancel();
    _heartbeatTimer?.cancel();
    _controller.close();
  }
}
