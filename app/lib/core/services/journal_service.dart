import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import '../database/app_database.dart';
import '../network/api_client.dart';

class SessionTurnData {
  final String questionText;
  final String transcript;
  final double? score;
  final List<Map<String, String>> mistakes;
  final List<String> vocabulary;

  SessionTurnData({
    required this.questionText,
    required this.transcript,
    this.score,
    required this.mistakes,
    required this.vocabulary,
  });
}

class JournalService {
  final AppDatabase _db;
  final ApiClient _apiClient;

  JournalService(this._db, this._apiClient);

  Future<JournalEntry> createJournalEntryFromSession({
    required String sessionId,
    required String title,
    required DateTime date,
    required int durationSeconds,
    required double overallScore,
    required List<SessionTurnData> turns,
  }) async {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final formattedDate = dateFormat.format(date);
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    final durationStr = '${minutes}m ${seconds}s';

    final allMistakes = <Map<String, String>>[];
    final allVocab = <String>{};

    for (final turn in turns) {
      allMistakes.addAll(turn.mistakes);
      allVocab.addAll(turn.vocabulary);
    }

    final buffer = StringBuffer();
    buffer.writeln('---');
    buffer.writeln('tags:');
    buffer.writeln('  - english-brain');
    buffer.writeln('  - session-journal');
    buffer.writeln('date: ${date.toIso8601String()}');
    buffer.writeln('session_id: "$sessionId"');
    buffer.writeln('score: ${overallScore.toStringAsFixed(1)}');
    buffer.writeln('duration_seconds: $durationSeconds');
    buffer.writeln('---');
    buffer.writeln();
    buffer.writeln('# Diario de Práctica: $title');
    buffer.writeln('**Fecha:** $formattedDate  ');
    buffer.writeln('**Duración:** $durationStr  ');
    buffer.writeln('**Puntuación General:** ${overallScore.toStringAsFixed(1)} / 100  ');
    buffer.writeln('**Preguntas Respondidas:** ${turns.length}  ');
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln();
    buffer.writeln('## Intervenciones y Transcripciones');
    for (int i = 0; i < turns.length; i++) {
      final t = turns[i];
      buffer.writeln('### Pregunta ${i + 1}: ${t.questionText}');
      buffer.writeln('**Mi respuesta:**');
      buffer.writeln('> "${t.transcript.isEmpty ? '(Sin transcripción)' : t.transcript}"');
      if (t.score != null) {
        buffer.writeln('**Puntuación del Turno:** ${t.score!.toStringAsFixed(1)} / 100  ');
      }
      buffer.writeln();
    }

    buffer.writeln('---');
    buffer.writeln();
    buffer.writeln('## Errores y Reglas Gramaticales');
    if (allMistakes.isEmpty) {
      buffer.writeln('*¡Sin errores gramaticales detectados en esta sesión!*');
    } else {
      for (final m in allMistakes) {
        final orig = m['original'] ?? '';
        final corr = m['correction'] ?? '';
        final rule = m['rule'] ?? '';
        final cat = m['category'] ?? 'Grammar';
        buffer.writeln('- **[$cat] Error:** *"$orig"*');
        buffer.writeln('  - **Corrección:** `$corr`');
        if (rule.isNotEmpty) {
          buffer.writeln('  - **Regla:** $rule');
        }
      }
    }

    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln();
    buffer.writeln('## Vocabulario Clave para Anki / FSRS');
    if (allVocab.isEmpty) {
      buffer.writeln('*No se identificaron nuevos términos específicos.*');
    } else {
      for (final v in allVocab) {
        buffer.writeln('- `$v`');
      }
    }

    final mdContent = buffer.toString();
    final entryId = 'journal_$sessionId';

    await _db.into(_db.journalEntries).insertOnConflictUpdate(
          JournalEntriesCompanion.insert(
            id: entryId,
            sessionId: sessionId,
            title: title,
            date: date,
            durationSeconds: durationSeconds,
            questionsCount: turns.length,
            overallScore: overallScore,
            mistakesCount: allMistakes.length,
            mistakesJson: jsonEncode(allMistakes),
            vocabularyJson: jsonEncode(allVocab.toList()),
            markdownContent: mdContent,
            isExported: const Value(false),
          ),
        );

    final entry = await (_db.select(_db.journalEntries)
          ..where((tbl) => tbl.id.equals(entryId)))
        .getSingle();

    return entry;
  }

  /// Registra una entrada completa en la Bitácora para cualquier actividad
  /// (Inmersión, Vocabulario, Gramática, Entrevistas o Mazo FSRS).
  Future<JournalEntry> recordActivityJournal({
    required String title,
    required String category,
    required DateTime date,
    required int durationSeconds,
    required double overallScore,
    required int questionsCount,
    List<Map<String, String>> mistakes = const [],
    List<String> vocabulary = const [],
    String additionalNotes = '',
  }) async {
    final sessionId = 'act_${DateTime.now().millisecondsSinceEpoch}';
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final formattedDate = dateFormat.format(date);
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    final durationStr = '${minutes}m ${seconds}s';

    final buffer = StringBuffer();
    buffer.writeln('---');
    buffer.writeln('tags:');
    buffer.writeln('  - english-brain');
    buffer.writeln('  - bitacora');
    buffer.writeln('  - $category');
    buffer.writeln('date: ${date.toIso8601String()}');
    buffer.writeln('session_id: "$sessionId"');
    buffer.writeln('score: ${overallScore.toStringAsFixed(1)}');
    buffer.writeln('duration_seconds: $durationSeconds');
    buffer.writeln('---');
    buffer.writeln();
    buffer.writeln('# 📓 Bitácora de Práctica: $title');
    buffer.writeln('**Área:** `$category`  ');
    buffer.writeln('**Fecha:** $formattedDate  ');
    buffer.writeln('**Duración:** $durationStr  ');
    buffer.writeln('**Puntuación General:** ${overallScore.toStringAsFixed(1)} / 100  ');
    buffer.writeln('**Elementos / Preguntas:** $questionsCount  ');
    buffer.writeln();

    if (additionalNotes.isNotEmpty) {
      buffer.writeln('## Resumen Pedagógico');
      buffer.writeln(additionalNotes);
      buffer.writeln();
    }

    buffer.writeln('---');
    buffer.writeln('## Errores y Conceptos a Reforzar (FSRS)');
    if (mistakes.isEmpty) {
      buffer.writeln('✨ *¡Excelente sesión! 100% de aciertos sin errores detectados.*');
    } else {
      for (final m in mistakes) {
        final orig = m['original'] ?? '';
        final corr = m['correction'] ?? '';
        final rule = m['rule'] ?? '';
        buffer.writeln('- **Error:** *"$orig"*');
        if (corr.isNotEmpty) buffer.writeln('  - **Corrección esperada:** `$corr`');
        if (rule.isNotEmpty) buffer.writeln('  - **Regla / Explicación:** $rule');
      }
    }

    if (vocabulary.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('---');
      buffer.writeln('## Vocabulario y Expresiones Clave');
      for (final v in vocabulary) {
        buffer.writeln('- `$v`');
      }
    }

    final mdContent = buffer.toString();
    final entryId = 'journal_$sessionId';

    await _db.into(_db.journalEntries).insertOnConflictUpdate(
          JournalEntriesCompanion.insert(
            id: entryId,
            sessionId: sessionId,
            title: title,
            date: date,
            durationSeconds: durationSeconds,
            questionsCount: questionsCount,
            overallScore: overallScore,
            mistakesCount: mistakes.length,
            mistakesJson: jsonEncode(mistakes),
            vocabularyJson: jsonEncode(vocabulary),
            markdownContent: mdContent,
            isExported: const Value(false),
          ),
        );

    return (_db.select(_db.journalEntries)..where((tbl) => tbl.id.equals(entryId)))
        .getSingle();
  }

  Future<List<JournalEntry>> getJournalEntries() async {
    return (_db.select(_db.journalEntries)
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]))
        .get();
  }

  Future<JournalEntry?> getEntryBySessionId(String sessionId) async {
    return (_db.select(_db.journalEntries)
          ..where((tbl) => tbl.sessionId.equals(sessionId)))
        .getSingleOrNull();
  }

  Future<String> fetchWeeklyReportMarkdown() async {
    try {
      final report = await _apiClient.getWeeklyReport();
      return report.markdown_report;
    } catch (_) {
      // Offline fallback: generate local summary from local journals
      final entries = await getJournalEntries();
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      final recent = entries.where((e) => e.date.isAfter(weekAgo)).toList();

      final totalMistakes = recent.fold<int>(0, (sum, e) => sum + e.mistakesCount);
      final avgScore = recent.isEmpty
          ? 0.0
          : recent.fold<double>(0.0, (sum, e) => sum + e.overallScore) / recent.length;

      return '''# Resumen Semanal Local (Offline) - English Brain
**Fecha:** ${DateFormat('yyyy-MM-dd').format(now)}  
**Sesiones completadas en los últimos 7 días:** ${recent.length}  
**Puntuación Media:** ${avgScore.toStringAsFixed(1)} / 100  
**Total de Errores Detectados:** $totalMistakes  

> Sincroniza con el backend cuando tengas conexión para obtener el informe consolidado completo con LLM.
''';
    }
  }
}
