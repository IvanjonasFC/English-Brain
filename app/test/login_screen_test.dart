import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/core/network/api_client.dart';
import 'package:app/core/providers/app_providers.dart';
import 'package:app/core/storage/secure_storage_service.dart';
import 'package:app/core/storage/local_cache_service.dart';
import 'package:app/features/auth/login_screen.dart';
import 'package:app/l10n/app_localizations.dart';

class MockSuccessAuthApiClient extends ApiClient {
  MockSuccessAuthApiClient()
      : super(
          secureStorage: SecureStorageService(),
          cacheService: LocalCacheService(),
        );

  int loginCallCount = 0;
  String? lastApiKey;

  @override
  Future<String> login(String apiKey, {String? userId}) async {
    loginCallCount++;
    lastApiKey = apiKey;
    return 'mock-jwt-token-12345';
  }

  @override
  Future<Map<String, dynamic>> checkHealthDetailed() async {
    return {
      'status': 'healthy',
      'version': '1.0.0',
      'latency_ms': 15,
      'services': {
        'ollama': {'status': 'online'},
        'speaches': {'status': 'online'},
      },
    };
  }
}

class MockFailureAuthApiClient extends ApiClient {
  MockFailureAuthApiClient()
      : super(
          secureStorage: SecureStorageService(),
          cacheService: LocalCacheService(),
        );

  @override
  Future<String> login(String apiKey, {String? userId}) async {
    throw HumanizedApiException(
      'Clave de acceso incorrecta o no autorizada (401).',
      statusCode: 401,
    );
  }

  @override
  Future<Map<String, dynamic>> checkHealthDetailed() async {
    throw HumanizedApiException('Servidor no alcanzable');
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'server_base_url': 'http://192.168.1.50:8000',
    });
  });

  testWidgets('LoginScreen renders presets and inputs', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final mockApi = MockSuccessAuthApiClient();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(mockApi),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('es'),
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('English Brain'), findsOneWidget);
    expect(find.text('LAN Casa'), findsOneWidget);
    expect(find.text('WireGuard'), findsOneWidget);
    expect(find.text('HTTPS Caddy'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });

  testWidgets('LoginScreen failure displays humanized error message', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final mockApi = MockFailureAuthApiClient();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(mockApi),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('es'),
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Enter URL and API key and submit
    final urlField = find.widgetWithText(TextFormField, 'URL del Servidor (NAS / Docker)');
    await tester.enterText(urlField, 'http://192.168.1.50:8000');
    final keyField = find.widgetWithText(TextFormField, 'API Key de Acceso');
    expect(keyField, findsOneWidget);
    await tester.enterText(keyField, 'wrong-key');

    final loginBtn = find.byType(FilledButton);
    await tester.ensureVisible(loginBtn);
    await tester.tap(loginBtn);
    await tester.pumpAndSettle();

    expect(find.textContaining('Clave de acceso incorrecta'), findsOneWidget);
  });

  testWidgets('LoginScreen success calls login and executes callback', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final mockApi = MockSuccessAuthApiClient();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(mockApi),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('es'),
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final urlField = find.widgetWithText(TextFormField, 'URL del Servidor (NAS / Docker)');
    await tester.enterText(urlField, 'http://192.168.1.50:8000');
    final keyField = find.widgetWithText(TextFormField, 'API Key de Acceso');
    await tester.enterText(keyField, 'super-secret-key-123');

    final loginBtn = find.byType(FilledButton);
    await tester.ensureVisible(loginBtn);
    await tester.tap(loginBtn);
    await tester.pumpAndSettle();

    expect(mockApi.loginCallCount, 1);
    expect(mockApi.lastApiKey, 'super-secret-key-123');
  });
}
