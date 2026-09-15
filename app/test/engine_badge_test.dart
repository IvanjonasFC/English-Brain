import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/models/api_models.dart';
import 'package:app/core/theme/app_theme.dart';

void main() {
  group('TurnOut engine_used parsing & serialization', () {
    test('parses engine_used = "fast"', () {
      final json = {
        'id': 10,
        'session_id': 'sess-1',
        'question_id': 2,
        'transcript': 'Hello world',
        'ai_reply_text': 'Hi there',
        'ai_reply_audio_url': null,
        'evaluation': {
          'interviewer_reply': 'Hi there',
          'overall_score': 9,
          'fluency_feedback': 'Good',
          'grammar_corrections': [],
          'vocabulary_suggestions': [],
        },
        'created_at': DateTime.now().toIso8601String(),
        'engine_used': 'fast',
      };

      final turn = TurnOut.fromJson(json);
      expect(turn.engineUsed, 'fast');
      expect(turn.toJson()['engine_used'], 'fast');
    });

    test('parses engine_used = "standard"', () {
      final json = {
        'id': 11,
        'session_id': 'sess-2',
        'question_id': 3,
        'transcript': 'Hello again',
        'ai_reply_text': 'Welcome',
        'ai_reply_audio_url': null,
        'evaluation': {
          'interviewer_reply': 'Welcome',
          'overall_score': 8,
          'fluency_feedback': 'Great',
          'grammar_corrections': [],
          'vocabulary_suggestions': [],
        },
        'created_at': DateTime.now().toIso8601String(),
        'engine_used': 'standard',
      };

      final turn = TurnOut.fromJson(json);
      expect(turn.engineUsed, 'standard');
      expect(turn.toJson()['engine_used'], 'standard');
    });

    test('parses missing engine_used gracefully as null (legacy/cache compatibility)', () {
      final json = {
        'id': 12,
        'session_id': 'sess-3',
        'question_id': null,
        'transcript': 'Legacy data',
        'ai_reply_text': 'Understood',
        'ai_reply_audio_url': null,
        'evaluation': {
          'interviewer_reply': 'Understood',
          'overall_score': 7,
          'fluency_feedback': 'OK',
          'grammar_corrections': [],
          'vocabulary_suggestions': [],
        },
        'created_at': DateTime.now().toIso8601String(),
      };

      final turn = TurnOut.fromJson(json);
      expect(turn.engineUsed, isNull);
      expect(turn.toJson()['engine_used'], isNull);
    });
  });

  group('Engine Badge Rendering', () {
    Widget buildBadge(String? engineUsed) {
      if (engineUsed == null) return const SizedBox.shrink();
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: (engineUsed == 'fast' ? AppTheme.success : AppTheme.textSecondary)
                .withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(engineUsed == 'fast' ? Icons.bolt_rounded : Icons.cloud_off_rounded,
                  size: 13,
                  color: engineUsed == 'fast' ? AppTheme.success : AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text(
                engineUsed == 'fast' ? 'Motor rápido (GPU)' : 'Motor estándar',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: engineUsed == 'fast' ? AppTheme.success : AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    testWidgets('renders fast GPU badge when engineUsed is fast', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: buildBadge('fast'),
          ),
        ),
      );

      expect(find.text('Motor rápido (GPU)'), findsOneWidget);
      expect(find.byIcon(Icons.bolt_rounded), findsOneWidget);
    });

    testWidgets('renders standard engine badge when engineUsed is standard or other', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: buildBadge('standard'),
          ),
        ),
      );

      expect(find.text('Motor estándar'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
    });

    testWidgets('does not render badge when engineUsed is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: buildBadge(null),
          ),
        ),
      );

      expect(find.text('Motor rápido (GPU)'), findsNothing);
      expect(find.text('Motor estándar'), findsNothing);
      expect(find.byIcon(Icons.bolt_rounded), findsNothing);
      expect(find.byIcon(Icons.cloud_off_rounded), findsNothing);
    });
  });
}
