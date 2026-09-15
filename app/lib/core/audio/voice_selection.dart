/// Selección de voz neural (Kokoro).
///
/// Decisión: UNA sola voz en TODA la app — la que mejor pronuncia — para
/// máxima calidad y coherencia (sin alternar). Si algún día quieres otra,
/// cambia únicamente `best` por otra voz Kokoro válida en tu worker
/// (p.ej. 'af_heart', 'am_adam', 'bm_george', 'bf_emma'...).
class AppVoices {
  /// Placeholder histórico que enviaba la app.
  static const String placeholder = 'en-US-GuyNeural';

  /// La voz que suena en TODA la app.
  static const String best = 'am_michael';

  // Compatibilidad con los puntos de llamada existentes: todos apuntan a la voz única.
  static const String principal = best;
  static const String vocabulary = best;
  static const String immersion = best;

  /// Siempre la mejor voz, sin importar lo que pida el llamador
  /// (elimina cualquier alternancia por categoría).
  static String resolve(String requested, [String? text]) => best;
}
