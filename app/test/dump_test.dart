import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import '../lib/features/vocabulary/vocabulary_repository.dart';

void main() {
  test('Dump vocab', () {
    final packs = VocabularyRepository.packs;
    
    final list = packs.map((p) => {
      'id': p.id,
      'title': p.title,
      'description': p.description,
      'iconCodePoint': p.icon.codePoint,
      'iconFontFamily': p.icon.fontFamily,
      'level': p.level,
      'accentColorValue': p.accentColor.value,
      'terms': p.terms.map((t) => {
        'term': t.term,
        'ipa': t.ipa,
        'definition': t.definition,
        'exampleSentence': t.exampleSentence,
        'spanishHint': t.spanishHint,
        'category': t.category,
        'difficulty': t.difficulty,
        'relatedTerms': t.relatedTerms,
        'origin': t.origin,
      }).toList()
    }).toList();
    
    final jsonStr = jsonEncode(list);
    File('../backend/app/seed/vocab.json').writeAsStringSync(jsonStr);
  });
}
