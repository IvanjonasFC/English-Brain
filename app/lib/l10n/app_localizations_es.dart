// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'English Brain';

  @override
  String appVersion(String version) {
    return 'v$version';
  }

  @override
  String get navHome => 'Inicio';

  @override
  String get navInterview => 'Speaking';

  @override
  String get navVocabulary => 'Vocabulario';

  @override
  String get navGrammar => 'Gramática';

  @override
  String get navComprehension => 'Comprensión';

  @override
  String get navFsrs => 'Mazo FSRS';

  @override
  String get navProfile => 'Perfil';

  @override
  String get homeGreetingMorning => 'Buenos días';

  @override
  String get homeGreetingAfternoon => 'Buenas tardes';

  @override
  String get homeGreetingEvening => 'Buenas noches';

  @override
  String homeStreakDays(int count) {
    return 'Racha de $count días';
  }

  @override
  String homeTotalXp(int xp) {
    return '$xp XP';
  }

  @override
  String homeLevel(String level) {
    return 'Nivel $level';
  }

  @override
  String get homeDailyProgress => 'Meta diaria';

  @override
  String get homeModulesSection => 'Módulos';

  @override
  String get homeNextBestAction => 'Continúa donde lo dejaste';

  @override
  String get homeRecentActivity => 'Actividad reciente';

  @override
  String get homeMetricsSection => 'Estadísticas de hoy';

  @override
  String get homeSessionsToday => 'Sesiones hoy';

  @override
  String get homeWordsReviewed => 'Palabras repasadas';

  @override
  String get homeGrammarScore => 'Puntuación gramática';

  @override
  String get homeStreak => 'Racha';

  @override
  String get homeSeeAll => 'Ver todo';

  @override
  String get homeKeepGoing => '¡Sigue así!';

  @override
  String get homeStartSession => 'Iniciar sesión';

  @override
  String get homeResumePractice => 'Continuar práctica';

  @override
  String get homeNoActivity => 'Sin actividad hoy';

  @override
  String get homeStartFirstSession => 'Empieza tu primera sesión';

  @override
  String get homeConnectedToServer => 'Conectado';

  @override
  String get homeOfflineMode => 'Modo sin conexión';

  @override
  String get homeOfflineSyncing => 'Sincronizando...';

  @override
  String homePendingSync(int count) {
    return '$count pendientes';
  }

  @override
  String get interviewTitle => 'Simulador de Entrevista';

  @override
  String get interviewHubTitle => 'Hub de Entrevista';

  @override
  String get interviewHubSubtitle =>
      'Practica entrevistas técnicas, de RRHH y diseño de sistemas';

  @override
  String get interviewSelectCategory => 'Selecciona categoría';

  @override
  String get interviewSelectDifficulty => 'Selecciona dificultad';

  @override
  String get interviewSelectMode => 'Selecciona modo';

  @override
  String get interviewStartSession => 'Iniciar sesión';

  @override
  String get interviewContinueSession => 'Continuar sesión';

  @override
  String get interviewEndSession => 'Finalizar sesión';

  @override
  String interviewQuestion(int current, int total) {
    return 'Pregunta $current de $total';
  }

  @override
  String get interviewNoQuestions => 'No hay preguntas';

  @override
  String get interviewNoQuestionsSubtitle =>
      'Prueba una categoría o dificultad diferente';

  @override
  String get interviewRecordAnswer => 'Graba tu respuesta';

  @override
  String get interviewRecordingInProgress => 'Grabando...';

  @override
  String get interviewRecordingStop => 'Detener grabación';

  @override
  String get interviewUploading => 'Analizando tu respuesta...';

  @override
  String get interviewFeedbackTitle => 'Feedback de IA';

  @override
  String get interviewModelAnswer => 'Respuesta modelo';

  @override
  String get interviewNextQuestion => 'Siguiente pregunta';

  @override
  String get interviewPrevQuestion => 'Anterior';

  @override
  String get interviewBrowseQuestions => 'Explorar preguntas';

  @override
  String get interviewSearchPlaceholder => 'Buscar preguntas...';

  @override
  String get interviewSearchNoResults => 'Sin resultados';

  @override
  String interviewSearchResults(int count) {
    return '$count preguntas';
  }

  @override
  String get interviewTips => 'Consejos';

  @override
  String get interviewTipsToggle => 'Mostrar consejos';

  @override
  String get interviewStarGuide => 'Marco STAR';

  @override
  String get interviewStarSituation => 'Situación';

  @override
  String get interviewStarSituationHint =>
      'Contexto: ¿cuándo, dónde, en qué proyecto?';

  @override
  String get interviewStarTask => 'Tarea';

  @override
  String get interviewStarTaskHint => 'Tu responsabilidad o reto específico';

  @override
  String get interviewStarAction => 'Acción';

  @override
  String get interviewStarActionHint =>
      'Pasos concretos que tomaste — usa \'Yo hice\', no \'Nosotros\'';

  @override
  String get interviewStarResult => 'Resultado';

  @override
  String get interviewStarResultHint =>
      'Cuantifica el impacto: % de mejora, tiempo ahorrado';

  @override
  String get interviewModeLesson => 'Lección';

  @override
  String get interviewModeCheckpoint => 'Checkpoint';

  @override
  String get interviewModeMock => 'Entrevista Simulada';

  @override
  String get interviewModeShadowing => 'Shadowing';

  @override
  String get interviewScoreLabel => 'Puntuación';

  @override
  String get interviewSessionComplete => 'Sesión completada';

  @override
  String get interviewSessionSaved => 'Sesión guardada';

  @override
  String get interviewOfflineQueued =>
      'Guardado offline, se sincronizará al conectarse';

  @override
  String get interviewCategoryTech => 'Técnica';

  @override
  String get interviewCategoryHr => 'RRHH';

  @override
  String get interviewCategorySystemDesign => 'Diseño de Sistemas';

  @override
  String get interviewCategoryCloudArch => 'Arquitectura Cloud';

  @override
  String get interviewCategoryAiMl => 'IA / ML';

  @override
  String get interviewCategorySecurity => 'Seguridad';

  @override
  String get interviewCategoryLeadership => 'Liderazgo';

  @override
  String get interviewCategoryBehavioral => 'Comportamental';

  @override
  String get interviewCategoryVocab => 'Vocabulario';

  @override
  String get interviewCategoryAgile => 'Agile';

  @override
  String get interviewCategoryDatabases => 'Bases de datos';

  @override
  String get interviewCategoryNetworking => 'Redes';

  @override
  String get interviewCategoryDevops => 'DevOps';

  @override
  String get interviewDifficultyJunior => 'Junior';

  @override
  String get interviewDifficultyMid => 'Mid';

  @override
  String get interviewDifficultySenior => 'Senior';

  @override
  String get interviewDifficultyStrategic => 'Estratégico';

  @override
  String get vocabTitle => 'Vocabulario';

  @override
  String get vocabHubTitle => 'Hub de Vocabulario';

  @override
  String get vocabHubSubtitle => 'Domina el vocabulario técnico y profesional';

  @override
  String vocabPacksAvailable(int count) {
    return '$count packs disponibles';
  }

  @override
  String get vocabSelectPack => 'Selecciona un pack para practicar';

  @override
  String get vocabCardFront => 'Frontal';

  @override
  String get vocabCardBack => 'Trasera';

  @override
  String get vocabFlipCard => 'Girar tarjeta';

  @override
  String get vocabFlipToSpanish => 'Ver en español';

  @override
  String get vocabFlipToEnglish => 'Ver en inglés';

  @override
  String get vocabDefinition => 'Definición';

  @override
  String get vocabExample => 'Ejemplo';

  @override
  String get vocabMnemonic => 'Truco para recordar';

  @override
  String get vocabPronunciation => 'Pronunciación';

  @override
  String get vocabPlayAudio => 'Reproducir audio';

  @override
  String get vocabSlowAudio => 'Lento';

  @override
  String get vocabNormalAudio => 'Normal';

  @override
  String get vocabRecordPronunciation => 'Graba tu pronunciación';

  @override
  String get vocabRecording => 'Grabando...';

  @override
  String get vocabCheckPronunciation => 'Comprobar pronunciación';

  @override
  String get vocabAnalyzing => 'Analizando pronunciación...';

  @override
  String vocabPronunciationScore(int score) {
    return 'Puntuación de pronunciación: $score%';
  }

  @override
  String get vocabPronunciationGood => '¡Excelente pronunciación!';

  @override
  String get vocabPronunciationAverage => 'Bien, sigue practicando';

  @override
  String get vocabPronunciationNeedsWork => 'Necesita mejorar';

  @override
  String get vocabAddToFsrs => 'Añadir al mazo FSRS';

  @override
  String get vocabAddedToFsrs => 'Añadido a tu mazo de repaso';

  @override
  String get vocabNextWord => 'Siguiente palabra';

  @override
  String get vocabPrevWord => 'Anterior';

  @override
  String vocabWordCount(int current, int total) {
    return '$current / $total';
  }

  @override
  String vocabProgress(int percent) {
    return '$percent% dominado';
  }

  @override
  String get vocabMarkMastered => 'Marcar como dominado';

  @override
  String get vocabAlreadyMastered => '¡Dominado!';

  @override
  String get vocabDomainTech => 'Técnico';

  @override
  String get vocabDomainInterview => 'Entrevista';

  @override
  String get vocabDomainGeneral => 'General';

  @override
  String get vocabLevelLabel => 'Nivel';

  @override
  String get vocabPackCompleted => '¡Pack completado!';

  @override
  String get vocabPackCompletedSubtitle =>
      'Todas las palabras repasadas. Vuelve mañana para el repaso espaciado.';

  @override
  String get vocabNoPackSelected => 'Ningún pack seleccionado';

  @override
  String get vocabNoPackSelectedSubtitle =>
      'Vuelve atrás y selecciona un pack de vocabulario';

  @override
  String get grammarTitle => 'Gramática';

  @override
  String get grammarHubTitle => 'Hub de Gramática';

  @override
  String get grammarHubSubtitle =>
      'Domina la gramática inglesa de básico a avanzado';

  @override
  String get grammarSelectLevel => 'Selecciona nivel';

  @override
  String get grammarSelectUnit => 'Selecciona unidad';

  @override
  String get grammarCheckAnswer => 'Comprobar respuesta';

  @override
  String get grammarNextExercise => 'Siguiente ejercicio';

  @override
  String get grammarPrevExercise => 'Anterior';

  @override
  String grammarScore(int score) {
    return 'Puntuación: $score%';
  }

  @override
  String get grammarCorrect => '¡Correcto!';

  @override
  String get grammarIncorrect => 'Incorrecto';

  @override
  String get grammarExplanation => 'Explicación';

  @override
  String get grammarYourAnswer => 'Tu respuesta';

  @override
  String get grammarCorrectAnswer => 'Respuesta correcta';

  @override
  String get grammarLevelA1 => 'A1 — Principiante';

  @override
  String get grammarLevelA2 => 'A2 — Elemental';

  @override
  String get grammarLevelB1 => 'B1 — Intermedio';

  @override
  String get grammarLevelB2 => 'B2 — Intermedio Alto';

  @override
  String get grammarLevelC1 => 'C1 — Avanzado';

  @override
  String get grammarUnitComplete => '¡Unidad completada!';

  @override
  String grammarDrillsRemaining(int count) {
    return '$count ejercicios restantes';
  }

  @override
  String get grammarSkipExercise => 'Saltar';

  @override
  String get grammarHint => 'Pista';

  @override
  String get grammarShowHint => 'Mostrar pista';

  @override
  String grammarProgress(int current, int total) {
    return 'Ejercicio $current de $total';
  }

  @override
  String get grammarTypeMultipleChoice => 'Opción múltiple';

  @override
  String get grammarTypeFillBlank => 'Rellenar el hueco';

  @override
  String get grammarTypeReorder => 'Reordenar palabras';

  @override
  String get grammarTypeTranslate => 'Traducir';

  @override
  String get fsrsTitle => 'Mazo FSRS';

  @override
  String get fsrsSubtitle => 'Tarjetas de repetición espaciada';

  @override
  String fsrsCardsDue(int count) {
    return '$count tarjetas pendientes';
  }

  @override
  String fsrsNewCards(int count) {
    return '$count tarjetas nuevas';
  }

  @override
  String fsrsCardsLearning(int count) {
    return '$count aprendiendo';
  }

  @override
  String get fsrsStartReview => 'Iniciar repaso';

  @override
  String get fsrsNoCardsDue => '¡Todo al día!';

  @override
  String get fsrsNoCardsDueSubtitle =>
      'No hay tarjetas pendientes. Vuelve más tarde.';

  @override
  String get fsrsCardFront => 'Frontal';

  @override
  String get fsrsCardBack => 'Trasera (toca para revelar)';

  @override
  String get fsrsRevealAnswer => 'Mostrar Respuesta';

  @override
  String get fsrsRatingAgain => 'Otra vez';

  @override
  String get fsrsRatingHard => 'Difícil';

  @override
  String get fsrsRatingGood => 'Bien';

  @override
  String get fsrsRatingEasy => 'Fácil';

  @override
  String fsrsNextReview(String date) {
    return 'Próximo repaso: $date';
  }

  @override
  String get fsrsSessionComplete => 'Sesión de repaso completada';

  @override
  String get fsrsExportToAnki => 'Exportar a Anki';

  @override
  String get fsrsExporting => 'Exportando...';

  @override
  String get fsrsExported => 'Exportado correctamente';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileTotalXp => 'XP Total';

  @override
  String get profileWeeklyXp => 'Esta semana';

  @override
  String get profileStreak => 'días de racha';

  @override
  String get profileTimeStudied => 'Tiempo estudiado';

  @override
  String get profileSessions => 'Sesiones';

  @override
  String get profileUnitsCompleted => 'Unidades completadas';

  @override
  String get profileWordsMastered => 'Palabras dominadas';

  @override
  String get profileSpeakingScore => 'Puntuación speaking';

  @override
  String get profileListeningScore => 'Puntuación listening';

  @override
  String get profileSkillsSection => 'Habilidades';

  @override
  String get profileSkillGrammar => 'Gramática';

  @override
  String get profileSkillVocabulary => 'Vocabulario';

  @override
  String get profileSkillListening => 'Comprensión auditiva';

  @override
  String get profileSkillSpeaking => 'Expresión oral';

  @override
  String get profileActivitySection => 'Actividad de práctica';

  @override
  String get profileAchievementsSection => 'Logros';

  @override
  String get profileSettingsSection => 'Ajustes';

  @override
  String get profileAccount => 'Cuenta';

  @override
  String get profileAudio => 'Ajustes de audio';

  @override
  String get profileSync => 'Sincronización y datos';

  @override
  String get profileExport => 'Exportar datos';

  @override
  String get profilePrivacy => 'Privacidad';

  @override
  String get profileLogout => 'Cerrar sesión';

  @override
  String get profileLanguage => 'Idioma de la app';

  @override
  String get profileLanguageEs => 'Español';

  @override
  String get profileLanguageEn => 'Inglés';

  @override
  String get profileDailyGoal => 'Meta diaria';

  @override
  String profileDailyGoalMinutes(int minutes) {
    return '$minutes min / día';
  }

  @override
  String get profileCefrLevel => 'Nivel CEFR';

  @override
  String get profileTarget => 'Nivel objetivo';

  @override
  String profileLastActive(String date) {
    return 'Último acceso: $date';
  }

  @override
  String get profileNoAchievements => 'Sin logros todavía';

  @override
  String get profileNoAchievementsSubtitle =>
      'Completa sesiones para ganar insignias';

  @override
  String get profileBadgeUnlocked => '¡Desbloqueado!';

  @override
  String get profileBadgeLocked => 'Bloqueado';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsServerUrl => 'URL del servidor';

  @override
  String get settingsApiKey => 'Clave API';

  @override
  String get settingsSave => 'Guardar';

  @override
  String get settingsSaved => 'Ajustes guardados';

  @override
  String get settingsReset => 'Restablecer por defecto';

  @override
  String get settingsAppInfo => 'Información de la app';

  @override
  String get settingsVersion => 'Versión';

  @override
  String get settingsClearCache => 'Limpiar caché';

  @override
  String get settingsCacheCleared => 'Caché limpiada';

  @override
  String get loginTitle => 'Bienvenido';

  @override
  String get loginSubtitle => 'Inicia sesión en English Brain';

  @override
  String get loginUsername => 'Usuario';

  @override
  String get loginPassword => 'Contraseña';

  @override
  String get loginServerUrl => 'URL del servidor';

  @override
  String get loginSignIn => 'Iniciar sesión';

  @override
  String get loginSigningIn => 'Iniciando sesión...';

  @override
  String get loginError =>
      'Error de inicio de sesión. Comprueba tus credenciales.';

  @override
  String get loginForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get loginOfflineMode => 'Continuar sin conexión';

  @override
  String get onboardingTitle => 'English Brain';

  @override
  String get onboardingSubtitle =>
      'Tu entrenador de inglés con inteligencia artificial';

  @override
  String get onboardingStep1Title => 'Practica speaking';

  @override
  String get onboardingStep1Subtitle =>
      'Simulaciones de entrevistas reales con feedback de IA';

  @override
  String get onboardingStep2Title => 'Domina el vocabulario';

  @override
  String get onboardingStep2Subtitle =>
      'Tarjetas 3D con comprobación de pronunciación';

  @override
  String get onboardingStep3Title => 'Aprende gramática';

  @override
  String get onboardingStep3Subtitle => 'Ejercicios estructurados de A1 a C1';

  @override
  String get onboardingGetStarted => 'Empezar';

  @override
  String get onboardingSkip => 'Saltar';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingConfigServer => 'Configurar servidor';

  @override
  String get errorTitle => 'Algo ha salido mal';

  @override
  String get errorNoConnection => 'Sin conexión a internet';

  @override
  String get errorNoConnectionSubtitle =>
      'Modo offline activo. Los datos se sincronizarán al conectarse.';

  @override
  String get errorServerUnreachable => 'Servidor no disponible';

  @override
  String get errorServerUnreachableSubtitle =>
      'Comprueba la URL del servidor en ajustes';

  @override
  String get errorRetry => 'Reintentar';

  @override
  String get errorGeneric =>
      'Se ha producido un error. Por favor, inténtalo de nuevo.';

  @override
  String get errorTimeout => 'Tiempo de espera agotado';

  @override
  String get errorNotFound => 'No encontrado';

  @override
  String get errorUnauthorized =>
      'Sesión expirada. Por favor, inicia sesión de nuevo.';

  @override
  String get stateLoading => 'Cargando...';

  @override
  String get stateEmpty => 'Aún no hay nada aquí';

  @override
  String get stateEmptySubtitle => 'Inicia una sesión para ver tus datos aquí';

  @override
  String get stateSyncing => 'Sincronizando datos...';

  @override
  String get stateSyncComplete => 'Sincronización completada';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionConfirm => 'Confirmar';

  @override
  String get actionClose => 'Cerrar';

  @override
  String get actionShare => 'Compartir';

  @override
  String get actionCopy => 'Copiar';

  @override
  String get actionCopied => 'Copiado al portapapeles';

  @override
  String get actionRetry => 'Reintentar';

  @override
  String get actionContinue => 'Continuar';

  @override
  String get actionStart => 'Iniciar';

  @override
  String get actionStop => 'Detener';

  @override
  String get actionBack => 'Atrás';

  @override
  String get actionNext => 'Siguiente';

  @override
  String get actionFinish => 'Finalizar';

  @override
  String get actionSkip => 'Saltar';

  @override
  String get snackOfflineQueued =>
      'Guardado offline. Se sincronizará al conectarse.';

  @override
  String get snackSyncSuccess => 'Datos sincronizados correctamente';

  @override
  String get snackSyncError =>
      'Error de sincronización. Se reintentará automáticamente.';

  @override
  String get snackCopied => '¡Copiado!';

  @override
  String get snackSaved => 'Guardado';

  @override
  String snackError(String message) {
    return 'Error: $message';
  }

  @override
  String get badgeFirstSession => 'Primera sesión';

  @override
  String get badgeWeekStreak => 'Racha semanal';

  @override
  String get badgeVocabMaster => 'Maestro del vocabulario';

  @override
  String get badgeGrammarAce => 'As de la gramática';

  @override
  String get badgeFsrsReviewer => 'Revisor FSRS';

  @override
  String get badgePronunciationPro => 'Profesional de pronunciación';

  @override
  String get badgeMockInterview => 'Entrevista simulada';

  @override
  String get badgeCheckpoint => 'Checkpoint superado';

  @override
  String get badgeTopPerformer => 'Alto rendimiento';

  @override
  String get difficultyJunior => 'Junior';

  @override
  String get difficultyMid => 'Mid';

  @override
  String get difficultySenior => 'Senior';

  @override
  String get difficultyStrategic => 'Estratégico';

  @override
  String get levelA1 => 'A1';

  @override
  String get levelA2 => 'A2';

  @override
  String get levelB1 => 'B1';

  @override
  String get levelB2 => 'B2';

  @override
  String get levelC1 => 'C1';

  @override
  String get levelC2 => 'C2';

  @override
  String minutesShort(int min) {
    return '${min}m';
  }

  @override
  String hoursShort(int h) {
    return '${h}h';
  }

  @override
  String daysShort(int d) {
    return '${d}d';
  }

  @override
  String get actionPractice => 'Practicar';

  @override
  String get actionCreate => 'Crear';

  @override
  String get actionCheck => 'Comprobar';

  @override
  String get actionExport => 'Exportar';

  @override
  String get commonExitSession => 'Salir de la sesión';

  @override
  String get ttsListenNatural => 'Escuchar frase con voz natural de Microsoft';

  @override
  String get ttsListenCorrect => 'Escuchar frase correcta en inglés nativo';

  @override
  String get ttsListenInterviewer => 'Escuchar al entrevistador';

  @override
  String get ttsListenSlow => 'Escuchar lento (0.8x)';

  @override
  String get ttsPlayInterviewer => 'Reproducir voz del entrevistador';

  @override
  String get ttsListenNativeVocab =>
      'Escuchar en inglés nativo (Microsoft Neural Voice)';

  @override
  String get ttsListenFullPhrase => 'Escuchar frase completa';

  @override
  String get exportCopyMarkdown => 'Copiar Markdown a Portapapeles (Obsidian)';

  @override
  String get exportCopyMarkdownObsidian => 'Copiar Markdown para Obsidian';

  @override
  String get exportCopiedObsidian =>
      '¡Copiado! Listo para pegar en tu vault de Obsidian.';

  @override
  String get connLocalPc => 'Local PC';

  @override
  String get connLanHome => 'LAN Casa';

  @override
  String get connWireguard => 'WireGuard';

  @override
  String get connHttpsCaddy => 'HTTPS Caddy';

  @override
  String get loginServerUrlLabel => 'URL del Servidor (NAS / Docker)';

  @override
  String get loginApiKeyLabel => 'API Key de Acceso';

  @override
  String get onboardingConfigAndStart => 'Configurar Servidor y Comenzar';

  @override
  String get deckTitle => 'Mazo de Repaso FSRS';

  @override
  String get deckReload => 'Volver a Cargar Mazo';

  @override
  String get dictationTitle => 'Módulo de Dictado (Fase 2)';

  @override
  String get shadowingTitle => 'Módulo de Shadowing (Fase 2)';

  @override
  String get grammarGuidebook => 'Guía';

  @override
  String get interviewHistory => 'Historial de Sesiones';

  @override
  String get interviewJournal => 'Diario de Sesión (Obsidian)';

  @override
  String get interviewRandomQuestion => 'Pregunta Aleatoria';

  @override
  String get interviewYourTranscript => 'Tu Transcripción (Speech-to-Text)';

  @override
  String get interviewInterviewerReply => 'Réplica del Entrevistador';

  @override
  String get interviewGrammarCorrections => 'Correcciones Gramaticales';

  @override
  String get interviewRecommendedVocab => 'Vocabulario Recomendado';

  @override
  String get interviewListenModel => 'Escuchar Modelo (1.0x)';

  @override
  String get interviewListenSlowShort => 'Lenta (0.8x)';

  @override
  String interviewNextQuestionCount(int current, int total) {
    return 'Siguiente Pregunta ($current de $total)';
  }

  @override
  String profileSwitchedTo(String name) {
    return 'Perfil cambiado a $name';
  }

  @override
  String get profileCreateNew => 'Crear Nuevo Perfil';

  @override
  String get profileNewProfile => 'Nuevo Perfil';

  @override
  String get profileNameAlias => 'Nombre o Alias';

  @override
  String get profileRoleSpecialty => 'Rol / Especialidad';

  @override
  String get profileTargetCefr => 'Nivel CEFR Objetivo';

  @override
  String profileLoadError(String error) {
    return 'Error cargando perfil: $error';
  }

  @override
  String get profileSwitchUser => 'Cambiar de Usuario';

  @override
  String get profileAudioEngine => 'Motor de Audio & Pronunciación';

  @override
  String get profileAudioEngineSub => 'TTS Local Speaches • Velocidad 1.0x';

  @override
  String get profileAudioSnack =>
      'Configuración de audio: Speaches TTS local activo.';

  @override
  String get profileNasSync => 'Sincronización con NAS';

  @override
  String get profileNasSyncSub =>
      'PostgreSQL local / LAN • Auto-sync en background';

  @override
  String get profileNasSnack =>
      'Conexión con NAS verificada. Cola offline sincronizada.';

  @override
  String get profileExportTitle => 'Exportar Diario & Flashcards';

  @override
  String get profileExportSub =>
      'Markdown para Obsidian y paquete .apkg para Anki';

  @override
  String get profileExportSnack =>
      'Exportación lista en /export/apkg y diario en base local.';

  @override
  String get profileManageUsers => 'Administrar Perfiles Multiusuario';

  @override
  String profileActiveUser(String name) {
    return 'Usuario activo: $name';
  }

  @override
  String get profilePrivacyTitle => 'Privacidad & Caché Local';

  @override
  String get profilePrivacySub =>
      'Almacenamiento Drift seguro sin headers sensibles';

  @override
  String get profilePrivacySnack =>
      'Almacenamiento local sanitizado y conforme a normas de privacidad.';

  @override
  String get questionsTitle => 'Banco de Preguntas';

  @override
  String get questionsSearchHint => 'Buscar por tecnología o tema...';

  @override
  String get questionsNoResults => 'No se encontraron preguntas coincidentes.';

  @override
  String get questionsFullQuestion => 'Pregunta Completa:';

  @override
  String get questionsModelAnswer => 'Respuesta Modelo:';

  @override
  String get questionsInterviewTip => 'Consejo de Entrevista:';

  @override
  String get questionsPractice => 'Practicar esta pregunta';

  @override
  String get settingsTitleDiag => 'Configuración y Diagnóstico';

  @override
  String get settingsServerConn => 'Conexión con el Servidor';

  @override
  String get settingsServerAddr => 'Dirección del Servidor (Base URL)';

  @override
  String get settingsApiKeyAuth => 'API Key de Autenticación';

  @override
  String get settingsDiagnostics => 'Diagnóstico';

  @override
  String get settingsOfflineQueue => 'Cola de Grabaciones Offline';

  @override
  String get settingsForceSync => 'Forzar Sincronización de Cola';

  @override
  String get settingsSessionSecurity => 'Sesión y Seguridad';

  @override
  String get statsLogEfset => 'Registrar Puntaje EF SET';

  @override
  String get statsLevelScore => 'Nivel y Puntaje';

  @override
  String get statsEfsetUpdated => '¡Hito EF SET actualizado con éxito!';

  @override
  String get statsReportCopied => '¡Informe copiado al portapapeles!';

  @override
  String get statsTitle => 'Progreso & Diario';

  @override
  String get statsThisWeek => 'Esta Semana';

  @override
  String get statsLastWeek => 'Semana Anterior';

  @override
  String get statsMilestones => 'Hitos Desbloqueados';

  @override
  String get statsEfsetNote => 'Nota EF SET';

  @override
  String get statsTimeline => 'Línea Temporal de Sesiones';

  @override
  String get statsNoteCopied =>
      '¡Nota copiada al portapapeles! Lista para Obsidian.';

  @override
  String get statsErrorsBreakdown => 'Desglose de Errores';

  @override
  String statsErrorsLogged(int count) {
    return '$count errores registrados';
  }

  @override
  String get vocabBackToEnglish => 'Volver al Inglés';

  @override
  String get vocabRetryPronunciation => 'Reintentar pronunciación';

  @override
  String get vocabReviewInFsrs => 'Repasar en Mazo FSRS';

  @override
  String vocabSavedToFsrs(String term) {
    return '\'$term\' guardada en tu Mazo FSRS local';
  }

  @override
  String get vocabSearchHint => 'Buscar término o definición...';

  @override
  String get loginTagline =>
      'Coach de entrevistas técnicas privado y autoalojado';

  @override
  String get connPresets => 'Presets de Conexión';

  @override
  String get onboardingHeroSubtitle =>
      'Tu entrenador personal para simulacros de entrevistas técnicas en inglés, 100% privado y autoalojado.';

  @override
  String get deckDailyComplete => '¡Repaso Diario Completado!';

  @override
  String get deckDailyCompleteBody =>
      'Has repasado todas tus tarjetas pendientes con el algoritmo FSRS. La retención se optimiza en la memoria a largo plazo.';

  @override
  String get dictationHeading => 'Entrenamiento de Listening & Dictado';

  @override
  String get dictationBody =>
      'En la siguiente fase podrás escuchar fragmentos de audio en inglés técnico y transcribirlos para entrenar la discriminación auditiva y ortografía.';

  @override
  String get shadowingHeading => 'Técnica de Shadowing';

  @override
  String get shadowingBody =>
      'En la siguiente fase podrás repetir inmediatamente frases nativas sintetizadas por Piper/Kokoro, entrenando el ritmo, la entonación y la velocidad de respuesta para entrevistas reales.';

  @override
  String get grammarHintEsToggle => 'Ver pista en español';

  @override
  String get grammarPracticeComplete => '¡Sesión de Práctica Completada!';

  @override
  String get grammarContinueRoadmap => 'Continuar al Roadmap';

  @override
  String get grammarRepeatUnit => 'Repetir Ejercicios de esta Unidad';

  @override
  String get grammarStartDrills => 'Iniciar Drills Interactivos';

  @override
  String get grammarLearningPath => 'Ruta de Gramática';

  @override
  String get grammarInteractiveSession => 'Sesión Interactiva';

  @override
  String get grammarKeyRule => 'Regla Clave:';

  @override
  String get grammarTipsEsToggle => 'Ver consejos en español';

  @override
  String get homeNextBestActionLabel => 'SIGUIENTE MEJOR ACCIÓN';

  @override
  String get homeContinuePath => 'Continuar Ruta Guiada';

  @override
  String get homeYourLearningPath => 'Tu Ruta de Aprendizaje';

  @override
  String get homeTodayFocus => 'Tu Foco de Hoy';

  @override
  String get homeTrainingModules => 'Módulos de Entrenamiento';

  @override
  String get homeCommProgress => 'Tu Progreso de Comunicación';

  @override
  String get interviewHubAdaptive =>
      'Simulador adaptativo con análisis fonético Whisper y evaluación STAR.';

  @override
  String get interviewSessionConfig => 'Configuración de la Sesión';

  @override
  String get interviewSkillsAssessed =>
      'Habilidades evaluadas: Pronunciación y Fonética (Whisper), Estructura STAR, Detección de Muletillas y Precisión Gramatical.';

  @override
  String get interviewStartPractice => 'Iniciar Sesión de Práctica';

  @override
  String get interviewSearchNoTermResults =>
      'No se encontraron preguntas con ese término.';

  @override
  String get interviewShadowingPhrase =>
      'Frase modelo para repetir (Shadowing):';

  @override
  String get interviewKeyVocabInclude =>
      'Vocabulario clave recomendado para incluir:';

  @override
  String get interviewStarMethod => 'Método STAR para estructurar tu respuesta';

  @override
  String get interviewPronunciationEval => 'Evaluación de Pronunciación & Voz';

  @override
  String get interviewComplexPhonetics =>
      'Términos técnicos con fonética compleja detectados:';

  @override
  String get interviewModelPhraseRef =>
      'Frase Modelo de Referencia (Senior IT)';

  @override
  String get interviewModelPhraseRefSub =>
      'Aprende cómo respondería un ingeniero senior con el método STAR';

  @override
  String get profileSwitchUserTitle => 'Cambiar Perfil de Usuario';

  @override
  String get profileSwitchUserBody =>
      'Elige el perfil activo para estudiar y sincronizar tus métricas independientes en el NAS:';

  @override
  String get profileGlobalProgress => 'Progreso Global & Experiencia';

  @override
  String get profileKeyMetrics => 'Métricas Clave de Aprendizaje';

  @override
  String get profileMasteryBySkill => 'Nivel de Dominio por Skill';

  @override
  String get profileConsistencyActivity => 'Consistencia & Actividad';

  @override
  String get profileLast30Days => 'Últimos 30 días';

  @override
  String get profileHeatmap30 => 'Heatmap 30 Días';

  @override
  String get profileLess => 'Menos';

  @override
  String get profileMore => 'Más';

  @override
  String get profileAchievementsCheckpoints => 'Logros & Checkpoints';

  @override
  String get profileSystemAccountConfig => 'Configuración del Sistema & Cuenta';

  @override
  String get settingsLogoutConfirmBody =>
      'Se eliminarán el token JWT y la API Key del almacenamiento seguro. ¿Deseas continuar?';

  @override
  String get settingsPresetHelp =>
      'Selecciona un preset de acceso o introduce la URL directa de tu NAS o túnel.';

  @override
  String get settingsOfflineQueueHelp =>
      'Las respuestas grabadas sin conexión al servidor se almacenan localmente y se sincronizan en segundo plano.';

  @override
  String get settingsSessionHelp =>
      'Tu sesión almacena un JWT criptográfico en Flutter Secure Storage. Puedes cerrar sesión para limpiar credenciales.';

  @override
  String get statsEfsetHelp =>
      'Introduce tu puntuación oficial de la prueba EF SET (ejemplo: C1 - 65/100 o B2 - 58/100):';

  @override
  String get statsWeeklyReportObsidian => 'Informe Semanal Obsidian';

  @override
  String get statsWeeklyReportSub =>
      'Exporta tu resumen semanal con errores y progreso en Markdown.';

  @override
  String get statsWeeklyErrorComparison => 'Comparativa Semanal de Errores';

  @override
  String get statsNoSessions => 'Sin sesiones en el diario todavía';

  @override
  String get statsNoSessionsSub =>
      'Cada simulación completada guardará automáticamente una nota en SQLite lista para Obsidian.';

  @override
  String get statsHabitTip =>
      'El hábito diario de 15 minutos marca la diferencia en tu fluidez.';

  @override
  String get statsAnswerActivity7d =>
      'Actividad de Respuestas (Últimos 7 Días)';

  @override
  String get vocabFlipCardHint => 'Girar tarjeta (Traducción y Mnemotecnia)';

  @override
  String get vocabTranslationContext => 'TRADUCCIÓN Y CONTEXTO';

  @override
  String get vocabDefinitionEquiv => 'Definición y Equivalencia:';

  @override
  String get vocabMnemonicTip => 'Tip Mnemotécnico para Recordar:';

  @override
  String get vocabAnalyzingWhisper =>
      'Analizando pronunciación y claridad con Whisper...';

  @override
  String get vocabRecordingPrompt =>
      'Grabando... Pronuncia el término en inglés';

  @override
  String get vocabTestPronunciation => 'Probar mi pronunciación (Grabar voz)';

  @override
  String get vocabPacksThematic => 'Packs Temáticos de Ingeniería (7 Tracks)';

  @override
  String get vocabHubMasterSub =>
      'Domina fonética IPA, pronunciación Microsoft TTS (1.0x/0.8x) y contexto IT real.';

  @override
  String get vocabPhoneticsAudioQuiz =>
      'Fonética IPA • Audio 1.0x/0.8x • Quizzes';

  @override
  String get vocabPronunciationTools =>
      'Herramientas de Pronunciación & IPA Curadas';

  @override
  String get vocabTrainingPath => 'Ruta de Vocabulario';

  @override
  String get vocabNoSearchResults =>
      'No se encontraron términos para esta búsqueda.';

  @override
  String get vocabChooseMode => '¿Cómo quieres practicar este pack?';

  @override
  String get vocabModeLearn => 'Aprender';

  @override
  String get vocabModePractice => 'Practicar';

  @override
  String get vocabModeLearnSub =>
      'Explora tarjetas con definición, ejemplo y pronunciación';

  @override
  String get vocabModePracticeSub =>
      'Sesión mixta adaptativa; los fallos van a tu mazo FSRS';

  @override
  String get interviewPacksTitle => 'Packs de Entrevista Estructurados';

  @override
  String get interviewPacksSubtitle =>
      'Simulaciones pedagógicas con objetivo claro, tips y evaluación STAR';

  @override
  String get interviewPackStart => 'Empezar Entrenamiento';

  @override
  String get interviewPackObjective => 'Objetivo de la sesión';

  @override
  String get interviewPackFeedbackFocus => 'Enfoque de evaluación';

  @override
  String interviewPackEstimatedTime(Object minutes) {
    return '$minutes min estimados';
  }

  @override
  String get interviewPackSkillsCovered => 'Habilidades trabajadas';

  @override
  String get interviewPackTips => 'Consejos tácticos';

  @override
  String get interviewPackBack => 'Volver';
}
