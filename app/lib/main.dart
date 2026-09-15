import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:async';
import 'core/services/client_logger.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/database/app_database.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/storage/local_cache_service.dart';
import 'core/network/api_client.dart';
import 'core/audio/offline_queue_service.dart';
import 'core/services/sync_service.dart';
import 'core/providers/app_providers.dart';
import 'core/services/shorebird_update_service.dart';
import 'l10n/app_localizations.dart';

const String offlineQueueTask = "drainOfflineQueue";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final db = AppDatabase();
      final secure = SecureStorageService();
      final cache = LocalCacheService();
      final api = ApiClient(secureStorage: secure, cacheService: cache);
      final queue = OfflineQueueService(db, api);
      final sync = DatabaseSyncService(db, api, queue);
      await sync.syncAll();
      await db.close();
      return true;
    } catch (_) {
      return false;
    }
  });
}

void main() {
  runZonedGuarded(() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    ClientLogger.error('flutter', details.exception, details.stack);
  };
  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    ClientLogger.error('platform', error, stack);
    return true;
  };

  if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
    try {
      await Workmanager().initialize(
        callbackDispatcher,
      );
      await Workmanager().registerPeriodicTask(
        "offline-queue-drain-periodic",
        offlineQueueTask,
        frequency: const Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      );
    } catch (_) {}
  }

  // Init DEFENSIVO: ningun fallo aqui puede impedir que la UI arranque
  // (si no, la app se queda colgada en la splash nativa para siempre).
  String? savedLocale;
  bool savedLight = true;
  double savedScale = 1.0;
  try {
    final prefs = await SharedPreferences.getInstance();
    savedLocale = prefs.getString('app_locale');
    savedLight = prefs.getBool('theme_light') ?? true;
    savedScale = prefs.getDouble('content_scale') ?? 1.0;
  } catch (e, s) {
    ClientLogger.error('boot_prefs', e, s);
  }
  AppTheme.applyLight(savedLight);

  // Restaurar la cuenta activa (multiusuario). Si el secure storage falla en el
  // primer arranque, NO bloqueamos el arranque de la app.
  String? savedUserId;
  try {
    savedUserId = await SecureStorageService().getActiveUserId();
  } catch (e, s) {
    ClientLogger.error('boot_secure', e, s);
  }

  runApp(ProviderScope(
    overrides: [
      if (savedLocale != null && savedLocale.isNotEmpty)
        localeProvider.overrideWith((ref) => Locale(savedLocale!)),
      if (savedUserId != null && savedUserId.isNotEmpty)
        activeUserIdProvider.overrideWith((ref) => savedUserId!),
      themeIsLightProvider.overrideWith((ref) => savedLight),
      textScaleFactorProvider.overrideWith((ref) => savedScale),
    ],
    child: const EnglishBrainApp(),
  ));
  }, (error, stack) {
    ClientLogger.error('zone', error, stack);
  });
}

class _AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) => child;

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class EnglishBrainApp extends ConsumerStatefulWidget {
  const EnglishBrainApp({super.key});

  @override
  ConsumerState<EnglishBrainApp> createState() => _EnglishBrainAppState();
}

class _EnglishBrainAppState extends ConsumerState<EnglishBrainApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(shorebirdUpdateServiceProvider).initializeAndCheck();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLight = ref.watch(themeIsLightProvider);
    AppTheme.applyLight(isLight);
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);
    final textScale = ref.watch(textScaleFactorProvider);

    return MaterialApp.router(
      title: 'English Brain',
      scrollBehavior: _AppScrollBehavior(),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: router,
      locale: locale,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
          child: UpdateNotificationHost(
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      supportedLocales: const [
        Locale('es'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
