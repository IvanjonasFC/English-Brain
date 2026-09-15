// GENERATED CODE - DO NOT MODIFY BY HAND
// Generated from backend/openapi.json via scripts/generate_dart_models.py
// ignore_for_file: non_constant_identifier_names, unnecessary_question_mark, unnecessary_cast, dead_code, camel_case_types

class Body_submit_answer_api_sessions__session_id__answer_post {
  final String file;
  final int? question_id;

  const Body_submit_answer_api_sessions__session_id__answer_post({
    required this.file,
    this.question_id,
  });

  factory Body_submit_answer_api_sessions__session_id__answer_post.fromJson(Map<String, dynamic> json) {
    return Body_submit_answer_api_sessions__session_id__answer_post(
      file: json['file'] as String,
      question_id: json['question_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'file': file,
      'question_id': question_id,
    };
  }
}

class CardOut {
  final int id;
  final int? mistake_id;
  final String front;
  final String back;
  final int state;
  final double difficulty;
  final double stability;
  final DateTime due_date;
  final DateTime? last_review;
  final int reps;
  final int lapses;
  final String? sourceType;
  final String? itemType;
  final String? unitOrPackId;
  final String? skill;

  const CardOut({
    required this.id,
    this.mistake_id,
    required this.front,
    required this.back,
    required this.state,
    required this.difficulty,
    required this.stability,
    required this.due_date,
    this.last_review,
    required this.reps,
    required this.lapses,
    this.sourceType,
    this.itemType,
    this.unitOrPackId,
    this.skill,
  });

  /// Canonical origin family for the transversal deck.
  /// Falls back to 'vocabulary' for legacy cards missing sourceType/skill.
  String get effectiveOrigin {
    final src = (sourceType ?? '').trim().toLowerCase();
    final sk = (skill ?? '').trim().toLowerCase();

    if (src.contains('grammar') || sk.contains('grammar')) {
      return 'grammar';
    }
    if (src.contains('interview') || sk.contains('speaking') || src.contains('speaking')) {
      return 'interview';
    }
    if (src.contains('listening') || sk.contains('listening')) {
      return 'listening';
    }
    return 'vocabulary';
  }

  factory CardOut.fromJson(Map<String, dynamic> json) {
    return CardOut(
      id: (json['id'] as num).toInt(),
      mistake_id: json['mistake_id'],
      front: json['front'] as String,
      back: json['back'] as String,
      state: (json['state'] as num).toInt(),
      difficulty: (json['difficulty'] as num).toDouble(),
      stability: (json['stability'] as num).toDouble(),
      due_date: DateTime.parse(json['due_date'] as String),
      last_review: json['last_review'] != null ? DateTime.parse(json['last_review'] as String) : null,
      reps: (json['reps'] as num).toInt(),
      lapses: (json['lapses'] as num).toInt(),
      sourceType: (json['source_type'] ?? json['sourceType']) as String?,
      itemType: (json['item_type'] ?? json['itemType']) as String?,
      unitOrPackId: (json['unit_or_pack_id'] ?? json['unit_id'] ?? json['unitOrPackId']) as String?,
      skill: json['skill'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mistake_id': mistake_id,
      'front': front,
      'back': back,
      'state': state,
      'difficulty': difficulty,
      'stability': stability,
      'due_date': due_date.toIso8601String(),
      'last_review': last_review?.toIso8601String(),
      'reps': reps,
      'lapses': lapses,
      'source_type': sourceType,
      'item_type': itemType,
      'unit_or_pack_id': unitOrPackId,
      'skill': skill,
    };
  }
}

class CardReviewIn {
  final int rating;

  const CardReviewIn({
    required this.rating,
  });

  factory CardReviewIn.fromJson(Map<String, dynamic> json) {
    return CardReviewIn(
      rating: (json['rating'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
    };
  }
}

class GrammarCorrection {
  final String original;
  final String correction;
  final String explanation;

  const GrammarCorrection({
    required this.original,
    required this.correction,
    required this.explanation,
  });

  factory GrammarCorrection.fromJson(Map<String, dynamic> json) {
    return GrammarCorrection(
      original: json['original'] as String,
      correction: json['correction'] as String,
      explanation: json['explanation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'original': original,
      'correction': correction,
      'explanation': explanation,
    };
  }
}

class HTTPValidationError {
  final List<ValidationError>? detail;

  const HTTPValidationError({
    this.detail,
  });

  factory HTTPValidationError.fromJson(Map<String, dynamic> json) {
    return HTTPValidationError(
      detail: (json['detail'] as List<dynamic>?)?.map((e) => ValidationError.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detail': detail?.map((e) => e.toJson()).toList(),
    };
  }
}

class LLMEvaluationResult {
  final String interviewer_reply;
  final List<GrammarCorrection>? grammar_corrections;
  final List<VocabularySuggestion>? vocabulary_suggestions;
  final int overall_score;
  final String fluency_feedback;
  final PronunciationFeedback? pronunciation_feedback;

  const LLMEvaluationResult({
    required this.interviewer_reply,
    this.grammar_corrections,
    this.vocabulary_suggestions,
    required this.overall_score,
    required this.fluency_feedback,
    this.pronunciation_feedback,
  });

  factory LLMEvaluationResult.fromJson(Map<String, dynamic> json) {
    return LLMEvaluationResult(
      interviewer_reply: json['interviewer_reply'] as String,
      grammar_corrections: (json['grammar_corrections'] as List<dynamic>?)?.map((e) => GrammarCorrection.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      vocabulary_suggestions: (json['vocabulary_suggestions'] as List<dynamic>?)?.map((e) => VocabularySuggestion.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      overall_score: (json['overall_score'] as num).toInt(),
      fluency_feedback: json['fluency_feedback'] as String,
      pronunciation_feedback: json['pronunciation_feedback'] != null ? PronunciationFeedback.fromJson(json['pronunciation_feedback'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'interviewer_reply': interviewer_reply,
      'grammar_corrections': grammar_corrections?.map((e) => e.toJson()).toList(),
      'vocabulary_suggestions': vocabulary_suggestions?.map((e) => e.toJson()).toList(),
      'overall_score': overall_score,
      'fluency_feedback': fluency_feedback,
      'pronunciation_feedback': pronunciation_feedback?.toJson(),
    };
  }
}

class LoginIn {
  final String api_key;

  const LoginIn({
    required this.api_key,
  });

  factory LoginIn.fromJson(Map<String, dynamic> json) {
    return LoginIn(
      api_key: json['api_key'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'api_key': api_key,
    };
  }
}

class MistakeOut {
  final int id;
  final int turn_id;
  final String category;
  final String original;
  final String correction;
  final String explanation;
  final DateTime timestamp;

  const MistakeOut({
    required this.id,
    required this.turn_id,
    required this.category,
    required this.original,
    required this.correction,
    required this.explanation,
    required this.timestamp,
  });

  factory MistakeOut.fromJson(Map<String, dynamic> json) {
    return MistakeOut(
      id: (json['id'] as num).toInt(),
      turn_id: (json['turn_id'] as num).toInt(),
      category: json['category'] as String,
      original: json['original'] as String,
      correction: json['correction'] as String,
      explanation: json['explanation'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'turn_id': turn_id,
      'category': category,
      'original': original,
      'correction': correction,
      'explanation': explanation,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class PronunciationFeedback {
  final int? score;
  final String? clarity;
  final List<String>? mispronounced_or_difficult_words;
  final List<String>? phonetic_tips;
  final List<String>? filler_words_detected;

  const PronunciationFeedback({
    this.score,
    this.clarity,
    this.mispronounced_or_difficult_words,
    this.phonetic_tips,
    this.filler_words_detected,
  });

  factory PronunciationFeedback.fromJson(Map<String, dynamic> json) {
    return PronunciationFeedback(
      score: (json['score'] as num?)?.toInt(),
      clarity: json['clarity'] as String?,
      mispronounced_or_difficult_words: (json['mispronounced_or_difficult_words'] as List<dynamic>?)?.map((e) => e is Map ? Map<String, dynamic>.from(e) : e).toList().cast() ?? [],
      phonetic_tips: (json['phonetic_tips'] as List<dynamic>?)?.map((e) => e is Map ? Map<String, dynamic>.from(e) : e).toList().cast() ?? [],
      filler_words_detected: (json['filler_words_detected'] as List<dynamic>?)?.map((e) => e is Map ? Map<String, dynamic>.from(e) : e).toList().cast() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'clarity': clarity,
      'mispronounced_or_difficult_words': mispronounced_or_difficult_words,
      'phonetic_tips': phonetic_tips,
      'filler_words_detected': filler_words_detected,
    };
  }
}

class QuestionOut {
  final int id;
  final String category;
  final String difficulty;
  final String title;
  final String text;
  final String? model_answer;
  final String? tips;
  final String? text_es;
  final String? title_es;
  final String? model_answer_es;
  final String? cefr;

  const QuestionOut({
    required this.id,
    required this.category,
    required this.difficulty,
    required this.title,
    required this.text,
    this.model_answer,
    this.tips,
    this.text_es,
    this.title_es,
    this.model_answer_es,
    this.cefr,
  });

  factory QuestionOut.fromJson(Map<String, dynamic> json) {
    return QuestionOut(
      id: (json['id'] as num).toInt(),
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      title: json['title'] as String,
      text: json['text'] as String,
      model_answer: json['model_answer'],
      tips: json['tips'],
      text_es: json['text_es'],
      title_es: json['title_es'],
      model_answer_es: json['model_answer_es'],
      cefr: json['cefr'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'difficulty': difficulty,
      'title': title,
      'text': text,
      'model_answer': model_answer,
      'tips': tips,
      'text_es': text_es,
      'title_es': title_es,
      'model_answer_es': model_answer_es,
      'cefr': cefr,
    };
  }
}

class SessionCreate {
  final String? category;
  final int? initial_question_id;

  const SessionCreate({
    this.category,
    this.initial_question_id,
  });

  factory SessionCreate.fromJson(Map<String, dynamic> json) {
    return SessionCreate(
      category: json['category'],
      initial_question_id: json['initial_question_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'initial_question_id': initial_question_id,
    };
  }
}

class SessionOut {
  final String id;
  final String user_id;
  final DateTime started_at;
  final DateTime? completed_at;
  final String status;
  final QuestionOut? initial_question;
  final String? initial_audio_url;

  const SessionOut({
    required this.id,
    required this.user_id,
    required this.started_at,
    this.completed_at,
    required this.status,
    this.initial_question,
    this.initial_audio_url,
  });

  factory SessionOut.fromJson(Map<String, dynamic> json) {
    return SessionOut(
      id: json['id'] as String,
      user_id: json['user_id'] as String,
      started_at: DateTime.parse(json['started_at'] as String),
      completed_at: json['completed_at'] != null ? DateTime.parse(json['completed_at'] as String) : null,
      status: json['status'] as String,
      initial_question: json['initial_question'] != null ? QuestionOut.fromJson(json['initial_question'] as Map<String, dynamic>) : null,
      initial_audio_url: json['initial_audio_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': user_id,
      'started_at': started_at.toIso8601String(),
      'completed_at': completed_at?.toIso8601String(),
      'status': status,
      'initial_question': initial_question?.toJson(),
      'initial_audio_url': initial_audio_url,
    };
  }
}

class StatsOut {
  final int total_sessions;
  final int total_turns;
  final int total_mistakes;
  final int cards_due_today;
  final int total_cards;
  final int streak_days;
  final Map<String, int> mistakes_by_category;
  final List<Map<String, dynamic>> weekly_activity;

  const StatsOut({
    required this.total_sessions,
    required this.total_turns,
    required this.total_mistakes,
    required this.cards_due_today,
    required this.total_cards,
    required this.streak_days,
    required this.mistakes_by_category,
    required this.weekly_activity,
  });

  factory StatsOut.fromJson(Map<String, dynamic> json) {
    return StatsOut(
      total_sessions: (json['total_sessions'] as num).toInt(),
      total_turns: (json['total_turns'] as num).toInt(),
      total_mistakes: (json['total_mistakes'] as num).toInt(),
      cards_due_today: (json['cards_due_today'] as num).toInt(),
      total_cards: (json['total_cards'] as num).toInt(),
      streak_days: (json['streak_days'] as num).toInt(),
      mistakes_by_category: (json['mistakes_by_category'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, (v as num).toInt())) ?? {},
      weekly_activity: (json['weekly_activity'] as List<dynamic>?)?.map((e) => e is Map ? Map<String, dynamic>.from(e) : e).toList().cast() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_sessions': total_sessions,
      'total_turns': total_turns,
      'total_mistakes': total_mistakes,
      'cards_due_today': cards_due_today,
      'total_cards': total_cards,
      'streak_days': streak_days,
      'mistakes_by_category': mistakes_by_category,
      'weekly_activity': weekly_activity,
    };
  }
}

class Token {
  final String access_token;
  final String? token_type;

  const Token({
    required this.access_token,
    this.token_type,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      access_token: json['access_token'] as String,
      token_type: json['token_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': access_token,
      'token_type': token_type,
    };
  }
}

class TurnOut {
  final int id;
  final String session_id;
  final int? question_id;
  final String transcript;
  final String ai_reply_text;
  final String? ai_reply_audio_url;
  final LLMEvaluationResult evaluation;
  final DateTime created_at;
  final String? engineUsed;

  const TurnOut({
    required this.id,
    required this.session_id,
    required this.question_id,
    required this.transcript,
    required this.ai_reply_text,
    required this.ai_reply_audio_url,
    required this.evaluation,
    required this.created_at,
    this.engineUsed,
  });

  factory TurnOut.fromJson(Map<String, dynamic> json) {
    return TurnOut(
      id: (json['id'] as num).toInt(),
      session_id: json['session_id'] as String,
      question_id: json['question_id'],
      transcript: json['transcript'] as String,
      ai_reply_text: json['ai_reply_text'] as String,
      ai_reply_audio_url: json['ai_reply_audio_url'],
      evaluation: LLMEvaluationResult.fromJson(json['evaluation'] as Map<String, dynamic>),
      created_at: DateTime.parse(json['created_at'] as String),
      engineUsed: json['engine_used'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': session_id,
      'question_id': question_id,
      'transcript': transcript,
      'ai_reply_text': ai_reply_text,
      'ai_reply_audio_url': ai_reply_audio_url,
      'evaluation': evaluation.toJson(),
      'created_at': created_at.toIso8601String(),
      'engine_used': engineUsed,
    };
  }
}

class ValidationError {
  final List<String?> loc;
  final String msg;
  final String type;
  final dynamic input;
  final Map<String, dynamic>? ctx;

  const ValidationError({
    required this.loc,
    required this.msg,
    required this.type,
    this.input,
    this.ctx,
  });

  factory ValidationError.fromJson(Map<String, dynamic> json) {
    return ValidationError(
      loc: (json['loc'] as List<dynamic>?)?.map((e) => e is Map ? Map<String, dynamic>.from(e) : e).toList().cast() ?? [],
      msg: json['msg'] as String,
      type: json['type'] as String,
      input: json['input'],
      ctx: json['ctx'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'loc': loc,
      'msg': msg,
      'type': type,
      'input': input,
      'ctx': ctx,
    };
  }
}

class VocabularySuggestion {
  final String term;
  final String context;
  final List<String>? alternatives;

  const VocabularySuggestion({
    required this.term,
    required this.context,
    this.alternatives,
  });

  factory VocabularySuggestion.fromJson(Map<String, dynamic> json) {
    return VocabularySuggestion(
      term: json['term'] as String,
      context: json['context'] as String,
      alternatives: (json['alternatives'] as List<dynamic>?)?.map((e) => e is Map ? Map<String, dynamic>.from(e) : e).toList().cast() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'term': term,
      'context': context,
      'alternatives': alternatives,
    };
  }
}

class WeeklyReportOut {
  final String week_range;
  final DateTime generated_at;
  final int total_sessions;
  final int total_turns;
  final int total_mistakes;
  final int? mistakes_this_week;
  final int? mistakes_last_week;
  final String markdown_report;

  const WeeklyReportOut({
    required this.week_range,
    required this.generated_at,
    required this.total_sessions,
    required this.total_turns,
    required this.total_mistakes,
    this.mistakes_this_week,
    this.mistakes_last_week,
    required this.markdown_report,
  });

  factory WeeklyReportOut.fromJson(Map<String, dynamic> json) {
    return WeeklyReportOut(
      week_range: json['week_range'] as String,
      generated_at: DateTime.parse(json['generated_at'] as String),
      total_sessions: (json['total_sessions'] as num).toInt(),
      total_turns: (json['total_turns'] as num).toInt(),
      total_mistakes: (json['total_mistakes'] as num).toInt(),
      mistakes_this_week: (json['mistakes_this_week'] as num?)?.toInt(),
      mistakes_last_week: (json['mistakes_last_week'] as num?)?.toInt(),
      markdown_report: json['markdown_report'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'week_range': week_range,
      'generated_at': generated_at.toIso8601String(),
      'total_sessions': total_sessions,
      'total_turns': total_turns,
      'total_mistakes': total_mistakes,
      'mistakes_this_week': mistakes_this_week,
      'mistakes_last_week': mistakes_last_week,
      'markdown_report': markdown_report,
    };
  }
}

class PronunciationResult {
  final String expected_term;
  final String recognized_text;
  final int score;
  final bool is_match;
  final String feedback;
  final String? tip;
  final bool sttOk;
  final String engineUsed;
  final double confidence;
  final List<String> wrongPhonemes;
  final String? audioUrl;

  const PronunciationResult({
    required this.expected_term,
    required this.recognized_text,
    required this.score,
    required this.is_match,
    required this.feedback,
    this.tip,
    this.sttOk = true,
    this.engineUsed = 'standard',
    this.confidence = 1.0,
    this.wrongPhonemes = const [],
    this.audioUrl,
  });

  factory PronunciationResult.fromJson(Map<String, dynamic> json) {
    return PronunciationResult(
      expected_term: json['expected_term'] as String? ?? '',
      recognized_text: json['recognized_text'] as String? ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      is_match: json['is_match'] as bool? ?? false,
      feedback: json['feedback'] as String? ?? '',
      tip: json['tip'] as String?,
      sttOk: json['stt_ok'] as bool? ?? true,
      engineUsed: json['engine_used'] as String? ?? 'standard',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      wrongPhonemes: (json['wrong_phonemes'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      audioUrl: json['audio_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expected_term': expected_term,
      'recognized_text': recognized_text,
      'score': score,
      'is_match': is_match,
      'feedback': feedback,
    };
  }
}

