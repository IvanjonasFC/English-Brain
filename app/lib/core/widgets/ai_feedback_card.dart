import 'package:flutter/material.dart';
import '../theme/tab_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../services/ai_service.dart';

/// Small badge showing which engine produced the AI feedback.
class AiEngineBadge extends StatelessWidget {
  final String engineUsed;
  const AiEngineBadge({super.key, required this.engineUsed});

  @override
  Widget build(BuildContext context) {
    final fast = engineUsed == 'fast';
    final color = fast ? AppTheme.success : AppTheme.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(fast ? Icons.bolt_rounded : Icons.cloud_off_rounded, size: 12, color: color),
          const SizedBox(width: 4),
          Text(fast ? 'IA GPU' : 'Local',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

Widget _sectionChips(String title, List<String> items, Color color) {
  if (items.isEmpty) return const SizedBox.shrink();
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 12),
      Text(title, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: items
            .map((e) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(e, style: TextStyle(color: color, fontSize: 12)),
                ))
            .toList(),
      ),
    ],
  );
}

/// Renders a grammar correction from the LLM.
class AiGrammarView extends StatelessWidget {
  final GrammarResult result;
  const AiGrammarView({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: TabTheme.grammar.accent, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Corrección con IA',
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            AiEngineBadge(engineUsed: result.engineUsed),
          ],
        ),
        const SizedBox(height: 14),
        if (!result.hasErrors)
          const Row(children: [
            Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 18),
            SizedBox(width: 8),
            Expanded(child: Text('Sin errores. ¡Bien!',
                style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold))),
          ])
        else ...[
          if (result.corrected != null) ...[
            Text(result.corrected!,
                style: const TextStyle(color: AppTheme.success, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
          ],
          if (result.explanation != null)
            Text(result.explanation!, style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, height: 1.4)),
          if (result.exampleCorrect != null) ...[
            const SizedBox(height: 10),
            Text('Ejemplo: ${result.exampleCorrect!}',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontStyle: FontStyle.italic)),
          ],
        ],
        if (result.cefrLevel != null) ...[
          const SizedBox(height: 12),
          Text('Nivel: ${result.cefrLevel}',
              style: TextStyle(color: TabTheme.grammar.accent, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ],
    );
  }
}

/// Renders a pedagogical vocabulary lookup from the LLM.
class AiVocabularyView extends StatelessWidget {
  final VocabularyResult result;
  const AiVocabularyView({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(result.word,
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            AiEngineBadge(engineUsed: result.engineUsed),
          ],
        ),
        Row(children: [
          if (result.ipa != null)
            Text(result.ipa!, style: TextStyle(color: TabTheme.vocabulary.accent, fontSize: 14)),
          if (result.cefrLevel != null) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: TabTheme.vocabulary.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
              child: Text(result.cefrLevel!, style: TextStyle(color: TabTheme.vocabulary.accent, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ]),
        if (result.translation.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(result.translation, style: const TextStyle(color: AppTheme.secondary, fontSize: 15, fontWeight: FontWeight.bold)),
        ],
        const SizedBox(height: 10),
        Text(result.definition, style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, height: 1.4)),
        if (result.examples.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Ejemplos', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          ...result.examples.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $e', style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, height: 1.3)),
              )),
        ],
        _sectionChips('Sinónimos', result.synonyms, TabTheme.vocabulary.accent),
        _sectionChips('Colocaciones', result.collocations, TabTheme.speaking.accent),
        if (result.memoryTip != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TabTheme.fsrs.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.lightbulb_outline_rounded, color: TabTheme.fsrs.accent, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(result.memoryTip!, style: TextStyle(color: AppTheme.textPrimary, fontSize: 13))),
            ]),
          ),
        ],
      ],
    );
  }
}

Widget _loading(String label) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const CircularProgressIndicator(color: AppTheme.primary),
        const SizedBox(height: 14),
        Text(label, style: TextStyle(color: AppTheme.textSecondary)),
      ]),
    );

Widget _sheetWrap(Widget child) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(child: child),
      ),
    );

/// Bottom sheet: LLM vocabulary lookup for [word].
Future<void> showAiVocabularySheet(BuildContext context, WidgetRef ref, String word) {
  final ai = ref.read(aiServiceProvider);
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => _sheetWrap(
      FutureBuilder<VocabularyResult?>(
        future: ai.lookupVocabulary(word),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return _loading('Consultando "$word" con IA...');
          }
          final r = snap.data;
          if (r == null) {
            return Text('No se pudo obtener la definición. ¿Worker GPU offline?',
                style: TextStyle(color: AppTheme.textSecondary));
          }
          return AiVocabularyView(result: r);
        },
      ),
    ),
  );
}

/// Bottom sheet: LLM grammar correction for [sentence].
Future<void> showAiGrammarSheet(BuildContext context, WidgetRef ref, String sentence) {
  final ai = ref.read(aiServiceProvider);
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => _sheetWrap(
      FutureBuilder<GrammarResult?>(
        future: ai.checkGrammar(sentence),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return _loading('Analizando con IA...');
          }
          final r = snap.data;
          if (r == null) {
            return Text('No se pudo analizar. ¿Worker GPU offline?',
                style: TextStyle(color: AppTheme.textSecondary));
          }
          return AiGrammarView(result: r);
        },
      ),
    ),
  );
}


