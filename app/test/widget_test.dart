import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:app/main.dart';
import 'package:app/core/providers/app_providers.dart';
import 'package:app/core/network/connectivity_service.dart';
import 'package:app/core/database/app_database.dart';
import 'package:app/core/audio/audio_recorder_controller.dart';
import 'package:app/core/network/api_client.dart';
import 'package:app/core/storage/secure_storage_service.dart';
import 'package:app/core/storage/local_cache_service.dart';

class FakeConnectivityService implements ConnectivityService {
  @override
  ConnectivityState get currentState =>
      const ConnectivityState(hasNetwork: true, hasServerAccess: true, statusMessage: 'Online');

  @override
  Stream<ConnectivityState> get statusStream => Stream.value(currentState);

  @override
  Future<ConnectivityState> checkServerReachability() async => currentState;

  @override
  void dispose() {}
}

/// Minimal no-op ApiClient so the smoke test can override the provider
/// without depending on deleted deck-flow test scaffolding.
class _SmokeApiClient extends ApiClient {
  _SmokeApiClient()
      : super(
          secureStorage: SecureStorageService(),
          cacheService: LocalCacheService(),
        );
}

void main() {
  testWidgets('EnglishBrainApp initial smoke test', (WidgetTester tester) async {
    final fakeConn = FakeConnectivityService();
    final inMemoryDb = AppDatabase(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          connectivityServiceProvider.overrideWithValue(fakeConn),
          connectivityStateProvider.overrideWith((ref) => fakeConn.statusStream),
          appDatabaseProvider.overrideWithValue(inMemoryDb),
          apiClientProvider.overrideWithValue(_SmokeApiClient()),
          audioRecorderProvider.overrideWith((ref) => AudioRecorderController()),
        ],
        child: const EnglishBrainApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(EnglishBrainApp), findsOneWidget);
    await inMemoryDb.close();
  });
}
