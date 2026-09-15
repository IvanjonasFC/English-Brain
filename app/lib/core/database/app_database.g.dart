// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SessionsLocalTable extends SessionsLocal
    with TableInfo<$SessionsLocalTable, SessionsLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _overallScoreMeta = const VerificationMeta(
    'overallScore',
  );
  @override
  late final GeneratedColumn<double> overallScore = GeneratedColumn<double>(
    'overall_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mode,
    startedAt,
    endedAt,
    overallScore,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionsLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('overall_score')) {
      context.handle(
        _overallScoreMeta,
        overallScore.isAcceptableOrUnknown(
          data['overall_score']!,
          _overallScoreMeta,
        ),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionsLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionsLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      overallScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}overall_score'],
      ),
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $SessionsLocalTable createAlias(String alias) {
    return $SessionsLocalTable(attachedDatabase, alias);
  }
}

class SessionsLocalData extends DataClass
    implements Insertable<SessionsLocalData> {
  final String id;
  final String mode;
  final DateTime startedAt;
  final DateTime? endedAt;
  final double? overallScore;
  final bool isSynced;
  const SessionsLocalData({
    required this.id,
    required this.mode,
    required this.startedAt,
    this.endedAt,
    this.overallScore,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['mode'] = Variable<String>(mode);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    if (!nullToAbsent || overallScore != null) {
      map['overall_score'] = Variable<double>(overallScore);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  SessionsLocalCompanion toCompanion(bool nullToAbsent) {
    return SessionsLocalCompanion(
      id: Value(id),
      mode: Value(mode),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      overallScore: overallScore == null && nullToAbsent
          ? const Value.absent()
          : Value(overallScore),
      isSynced: Value(isSynced),
    );
  }

  factory SessionsLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionsLocalData(
      id: serializer.fromJson<String>(json['id']),
      mode: serializer.fromJson<String>(json['mode']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      overallScore: serializer.fromJson<double?>(json['overallScore']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mode': serializer.toJson<String>(mode),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'overallScore': serializer.toJson<double?>(overallScore),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  SessionsLocalData copyWith({
    String? id,
    String? mode,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    Value<double?> overallScore = const Value.absent(),
    bool? isSynced,
  }) => SessionsLocalData(
    id: id ?? this.id,
    mode: mode ?? this.mode,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    overallScore: overallScore.present ? overallScore.value : this.overallScore,
    isSynced: isSynced ?? this.isSynced,
  );
  SessionsLocalData copyWithCompanion(SessionsLocalCompanion data) {
    return SessionsLocalData(
      id: data.id.present ? data.id.value : this.id,
      mode: data.mode.present ? data.mode.value : this.mode,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      overallScore: data.overallScore.present
          ? data.overallScore.value
          : this.overallScore,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionsLocalData(')
          ..write('id: $id, ')
          ..write('mode: $mode, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('overallScore: $overallScore, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, mode, startedAt, endedAt, overallScore, isSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionsLocalData &&
          other.id == this.id &&
          other.mode == this.mode &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.overallScore == this.overallScore &&
          other.isSynced == this.isSynced);
}

class SessionsLocalCompanion extends UpdateCompanion<SessionsLocalData> {
  final Value<String> id;
  final Value<String> mode;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<double?> overallScore;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const SessionsLocalCompanion({
    this.id = const Value.absent(),
    this.mode = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.overallScore = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsLocalCompanion.insert({
    required String id,
    required String mode,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.overallScore = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       mode = Value(mode),
       startedAt = Value(startedAt);
  static Insertable<SessionsLocalData> custom({
    Expression<String>? id,
    Expression<String>? mode,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<double>? overallScore,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mode != null) 'mode': mode,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (overallScore != null) 'overall_score': overallScore,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsLocalCompanion copyWith({
    Value<String>? id,
    Value<String>? mode,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<double?>? overallScore,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return SessionsLocalCompanion(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      overallScore: overallScore ?? this.overallScore,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (overallScore.present) {
      map['overall_score'] = Variable<double>(overallScore.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsLocalCompanion(')
          ..write('id: $id, ')
          ..write('mode: $mode, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('overallScore: $overallScore, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TurnsLocalTable extends TurnsLocal
    with TableInfo<$TurnsLocalTable, TurnsLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TurnsLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<int> questionId = GeneratedColumn<int>(
    'question_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _questionTextMeta = const VerificationMeta(
    'questionText',
  );
  @override
  late final GeneratedColumn<String> questionText = GeneratedColumn<String>(
    'question_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transcriptMeta = const VerificationMeta(
    'transcript',
  );
  @override
  late final GeneratedColumn<String> transcript = GeneratedColumn<String>(
    'transcript',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _audioPathMeta = const VerificationMeta(
    'audioPath',
  );
  @override
  late final GeneratedColumn<String> audioPath = GeneratedColumn<String>(
    'audio_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _feedbackJsonMeta = const VerificationMeta(
    'feedbackJson',
  );
  @override
  late final GeneratedColumn<String> feedbackJson = GeneratedColumn<String>(
    'feedback_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<double> score = GeneratedColumn<double>(
    'score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    questionId,
    questionText,
    transcript,
    audioPath,
    feedbackJson,
    score,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'turns_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<TurnsLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    }
    if (data.containsKey('question_text')) {
      context.handle(
        _questionTextMeta,
        questionText.isAcceptableOrUnknown(
          data['question_text']!,
          _questionTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_questionTextMeta);
    }
    if (data.containsKey('transcript')) {
      context.handle(
        _transcriptMeta,
        transcript.isAcceptableOrUnknown(data['transcript']!, _transcriptMeta),
      );
    } else if (isInserting) {
      context.missing(_transcriptMeta);
    }
    if (data.containsKey('audio_path')) {
      context.handle(
        _audioPathMeta,
        audioPath.isAcceptableOrUnknown(data['audio_path']!, _audioPathMeta),
      );
    }
    if (data.containsKey('feedback_json')) {
      context.handle(
        _feedbackJsonMeta,
        feedbackJson.isAcceptableOrUnknown(
          data['feedback_json']!,
          _feedbackJsonMeta,
        ),
      );
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TurnsLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TurnsLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}question_id'],
      ),
      questionText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_text'],
      )!,
      transcript: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transcript'],
      )!,
      audioPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_path'],
      ),
      feedbackJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feedback_json'],
      ),
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}score'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TurnsLocalTable createAlias(String alias) {
    return $TurnsLocalTable(attachedDatabase, alias);
  }
}

class TurnsLocalData extends DataClass implements Insertable<TurnsLocalData> {
  final int id;
  final String sessionId;
  final int? questionId;
  final String questionText;
  final String transcript;
  final String? audioPath;
  final String? feedbackJson;
  final double? score;
  final DateTime createdAt;
  const TurnsLocalData({
    required this.id,
    required this.sessionId,
    this.questionId,
    required this.questionText,
    required this.transcript,
    this.audioPath,
    this.feedbackJson,
    this.score,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<String>(sessionId);
    if (!nullToAbsent || questionId != null) {
      map['question_id'] = Variable<int>(questionId);
    }
    map['question_text'] = Variable<String>(questionText);
    map['transcript'] = Variable<String>(transcript);
    if (!nullToAbsent || audioPath != null) {
      map['audio_path'] = Variable<String>(audioPath);
    }
    if (!nullToAbsent || feedbackJson != null) {
      map['feedback_json'] = Variable<String>(feedbackJson);
    }
    if (!nullToAbsent || score != null) {
      map['score'] = Variable<double>(score);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TurnsLocalCompanion toCompanion(bool nullToAbsent) {
    return TurnsLocalCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      questionId: questionId == null && nullToAbsent
          ? const Value.absent()
          : Value(questionId),
      questionText: Value(questionText),
      transcript: Value(transcript),
      audioPath: audioPath == null && nullToAbsent
          ? const Value.absent()
          : Value(audioPath),
      feedbackJson: feedbackJson == null && nullToAbsent
          ? const Value.absent()
          : Value(feedbackJson),
      score: score == null && nullToAbsent
          ? const Value.absent()
          : Value(score),
      createdAt: Value(createdAt),
    );
  }

  factory TurnsLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TurnsLocalData(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      questionId: serializer.fromJson<int?>(json['questionId']),
      questionText: serializer.fromJson<String>(json['questionText']),
      transcript: serializer.fromJson<String>(json['transcript']),
      audioPath: serializer.fromJson<String?>(json['audioPath']),
      feedbackJson: serializer.fromJson<String?>(json['feedbackJson']),
      score: serializer.fromJson<double?>(json['score']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'questionId': serializer.toJson<int?>(questionId),
      'questionText': serializer.toJson<String>(questionText),
      'transcript': serializer.toJson<String>(transcript),
      'audioPath': serializer.toJson<String?>(audioPath),
      'feedbackJson': serializer.toJson<String?>(feedbackJson),
      'score': serializer.toJson<double?>(score),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TurnsLocalData copyWith({
    int? id,
    String? sessionId,
    Value<int?> questionId = const Value.absent(),
    String? questionText,
    String? transcript,
    Value<String?> audioPath = const Value.absent(),
    Value<String?> feedbackJson = const Value.absent(),
    Value<double?> score = const Value.absent(),
    DateTime? createdAt,
  }) => TurnsLocalData(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    questionId: questionId.present ? questionId.value : this.questionId,
    questionText: questionText ?? this.questionText,
    transcript: transcript ?? this.transcript,
    audioPath: audioPath.present ? audioPath.value : this.audioPath,
    feedbackJson: feedbackJson.present ? feedbackJson.value : this.feedbackJson,
    score: score.present ? score.value : this.score,
    createdAt: createdAt ?? this.createdAt,
  );
  TurnsLocalData copyWithCompanion(TurnsLocalCompanion data) {
    return TurnsLocalData(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      questionText: data.questionText.present
          ? data.questionText.value
          : this.questionText,
      transcript: data.transcript.present
          ? data.transcript.value
          : this.transcript,
      audioPath: data.audioPath.present ? data.audioPath.value : this.audioPath,
      feedbackJson: data.feedbackJson.present
          ? data.feedbackJson.value
          : this.feedbackJson,
      score: data.score.present ? data.score.value : this.score,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TurnsLocalData(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('questionId: $questionId, ')
          ..write('questionText: $questionText, ')
          ..write('transcript: $transcript, ')
          ..write('audioPath: $audioPath, ')
          ..write('feedbackJson: $feedbackJson, ')
          ..write('score: $score, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    questionId,
    questionText,
    transcript,
    audioPath,
    feedbackJson,
    score,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TurnsLocalData &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.questionId == this.questionId &&
          other.questionText == this.questionText &&
          other.transcript == this.transcript &&
          other.audioPath == this.audioPath &&
          other.feedbackJson == this.feedbackJson &&
          other.score == this.score &&
          other.createdAt == this.createdAt);
}

class TurnsLocalCompanion extends UpdateCompanion<TurnsLocalData> {
  final Value<int> id;
  final Value<String> sessionId;
  final Value<int?> questionId;
  final Value<String> questionText;
  final Value<String> transcript;
  final Value<String?> audioPath;
  final Value<String?> feedbackJson;
  final Value<double?> score;
  final Value<DateTime> createdAt;
  const TurnsLocalCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.questionText = const Value.absent(),
    this.transcript = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.feedbackJson = const Value.absent(),
    this.score = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TurnsLocalCompanion.insert({
    this.id = const Value.absent(),
    required String sessionId,
    this.questionId = const Value.absent(),
    required String questionText,
    required String transcript,
    this.audioPath = const Value.absent(),
    this.feedbackJson = const Value.absent(),
    this.score = const Value.absent(),
    required DateTime createdAt,
  }) : sessionId = Value(sessionId),
       questionText = Value(questionText),
       transcript = Value(transcript),
       createdAt = Value(createdAt);
  static Insertable<TurnsLocalData> custom({
    Expression<int>? id,
    Expression<String>? sessionId,
    Expression<int>? questionId,
    Expression<String>? questionText,
    Expression<String>? transcript,
    Expression<String>? audioPath,
    Expression<String>? feedbackJson,
    Expression<double>? score,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (questionId != null) 'question_id': questionId,
      if (questionText != null) 'question_text': questionText,
      if (transcript != null) 'transcript': transcript,
      if (audioPath != null) 'audio_path': audioPath,
      if (feedbackJson != null) 'feedback_json': feedbackJson,
      if (score != null) 'score': score,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TurnsLocalCompanion copyWith({
    Value<int>? id,
    Value<String>? sessionId,
    Value<int?>? questionId,
    Value<String>? questionText,
    Value<String>? transcript,
    Value<String?>? audioPath,
    Value<String?>? feedbackJson,
    Value<double?>? score,
    Value<DateTime>? createdAt,
  }) {
    return TurnsLocalCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      questionId: questionId ?? this.questionId,
      questionText: questionText ?? this.questionText,
      transcript: transcript ?? this.transcript,
      audioPath: audioPath ?? this.audioPath,
      feedbackJson: feedbackJson ?? this.feedbackJson,
      score: score ?? this.score,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<int>(questionId.value);
    }
    if (questionText.present) {
      map['question_text'] = Variable<String>(questionText.value);
    }
    if (transcript.present) {
      map['transcript'] = Variable<String>(transcript.value);
    }
    if (audioPath.present) {
      map['audio_path'] = Variable<String>(audioPath.value);
    }
    if (feedbackJson.present) {
      map['feedback_json'] = Variable<String>(feedbackJson.value);
    }
    if (score.present) {
      map['score'] = Variable<double>(score.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TurnsLocalCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('questionId: $questionId, ')
          ..write('questionText: $questionText, ')
          ..write('transcript: $transcript, ')
          ..write('audioPath: $audioPath, ')
          ..write('feedbackJson: $feedbackJson, ')
          ..write('score: $score, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ReviewLogsLocalTable extends ReviewLogsLocal
    with TableInfo<$ReviewLogsLocalTable, ReviewLogsLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewLogsLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<int> cardId = GeneratedColumn<int>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<int> state = GeneratedColumn<int>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueMeta = const VerificationMeta('due');
  @override
  late final GeneratedColumn<DateTime> due = GeneratedColumn<DateTime>(
    'due',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stabilityMeta = const VerificationMeta(
    'stability',
  );
  @override
  late final GeneratedColumn<double> stability = GeneratedColumn<double>(
    'stability',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<double> difficulty = GeneratedColumn<double>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _elapsedDaysMeta = const VerificationMeta(
    'elapsedDays',
  );
  @override
  late final GeneratedColumn<int> elapsedDays = GeneratedColumn<int>(
    'elapsed_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastElapsedDaysMeta = const VerificationMeta(
    'lastElapsedDays',
  );
  @override
  late final GeneratedColumn<int> lastElapsedDays = GeneratedColumn<int>(
    'last_elapsed_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledDaysMeta = const VerificationMeta(
    'scheduledDays',
  );
  @override
  late final GeneratedColumn<int> scheduledDays = GeneratedColumn<int>(
    'scheduled_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reviewMeta = const VerificationMeta('review');
  @override
  late final GeneratedColumn<DateTime> review = GeneratedColumn<DateTime>(
    'review',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cardId,
    rating,
    state,
    due,
    stability,
    difficulty,
    elapsedDays,
    lastElapsedDays,
    scheduledDays,
    review,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_logs_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReviewLogsLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    } else if (isInserting) {
      context.missing(_ratingMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('due')) {
      context.handle(
        _dueMeta,
        due.isAcceptableOrUnknown(data['due']!, _dueMeta),
      );
    } else if (isInserting) {
      context.missing(_dueMeta);
    }
    if (data.containsKey('stability')) {
      context.handle(
        _stabilityMeta,
        stability.isAcceptableOrUnknown(data['stability']!, _stabilityMeta),
      );
    } else if (isInserting) {
      context.missing(_stabilityMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    } else if (isInserting) {
      context.missing(_difficultyMeta);
    }
    if (data.containsKey('elapsed_days')) {
      context.handle(
        _elapsedDaysMeta,
        elapsedDays.isAcceptableOrUnknown(
          data['elapsed_days']!,
          _elapsedDaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_elapsedDaysMeta);
    }
    if (data.containsKey('last_elapsed_days')) {
      context.handle(
        _lastElapsedDaysMeta,
        lastElapsedDays.isAcceptableOrUnknown(
          data['last_elapsed_days']!,
          _lastElapsedDaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastElapsedDaysMeta);
    }
    if (data.containsKey('scheduled_days')) {
      context.handle(
        _scheduledDaysMeta,
        scheduledDays.isAcceptableOrUnknown(
          data['scheduled_days']!,
          _scheduledDaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledDaysMeta);
    }
    if (data.containsKey('review')) {
      context.handle(
        _reviewMeta,
        review.isAcceptableOrUnknown(data['review']!, _reviewMeta),
      );
    } else if (isInserting) {
      context.missing(_reviewMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReviewLogsLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewLogsLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_id'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}state'],
      )!,
      due: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due'],
      )!,
      stability: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stability'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}difficulty'],
      )!,
      elapsedDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_days'],
      )!,
      lastElapsedDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_elapsed_days'],
      )!,
      scheduledDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scheduled_days'],
      )!,
      review: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}review'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $ReviewLogsLocalTable createAlias(String alias) {
    return $ReviewLogsLocalTable(attachedDatabase, alias);
  }
}

class ReviewLogsLocalData extends DataClass
    implements Insertable<ReviewLogsLocalData> {
  final int id;
  final int cardId;
  final int rating;
  final int state;
  final DateTime due;
  final double stability;
  final double difficulty;
  final int elapsedDays;
  final int lastElapsedDays;
  final int scheduledDays;
  final DateTime review;
  final bool isSynced;
  const ReviewLogsLocalData({
    required this.id,
    required this.cardId,
    required this.rating,
    required this.state,
    required this.due,
    required this.stability,
    required this.difficulty,
    required this.elapsedDays,
    required this.lastElapsedDays,
    required this.scheduledDays,
    required this.review,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['card_id'] = Variable<int>(cardId);
    map['rating'] = Variable<int>(rating);
    map['state'] = Variable<int>(state);
    map['due'] = Variable<DateTime>(due);
    map['stability'] = Variable<double>(stability);
    map['difficulty'] = Variable<double>(difficulty);
    map['elapsed_days'] = Variable<int>(elapsedDays);
    map['last_elapsed_days'] = Variable<int>(lastElapsedDays);
    map['scheduled_days'] = Variable<int>(scheduledDays);
    map['review'] = Variable<DateTime>(review);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  ReviewLogsLocalCompanion toCompanion(bool nullToAbsent) {
    return ReviewLogsLocalCompanion(
      id: Value(id),
      cardId: Value(cardId),
      rating: Value(rating),
      state: Value(state),
      due: Value(due),
      stability: Value(stability),
      difficulty: Value(difficulty),
      elapsedDays: Value(elapsedDays),
      lastElapsedDays: Value(lastElapsedDays),
      scheduledDays: Value(scheduledDays),
      review: Value(review),
      isSynced: Value(isSynced),
    );
  }

  factory ReviewLogsLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewLogsLocalData(
      id: serializer.fromJson<int>(json['id']),
      cardId: serializer.fromJson<int>(json['cardId']),
      rating: serializer.fromJson<int>(json['rating']),
      state: serializer.fromJson<int>(json['state']),
      due: serializer.fromJson<DateTime>(json['due']),
      stability: serializer.fromJson<double>(json['stability']),
      difficulty: serializer.fromJson<double>(json['difficulty']),
      elapsedDays: serializer.fromJson<int>(json['elapsedDays']),
      lastElapsedDays: serializer.fromJson<int>(json['lastElapsedDays']),
      scheduledDays: serializer.fromJson<int>(json['scheduledDays']),
      review: serializer.fromJson<DateTime>(json['review']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cardId': serializer.toJson<int>(cardId),
      'rating': serializer.toJson<int>(rating),
      'state': serializer.toJson<int>(state),
      'due': serializer.toJson<DateTime>(due),
      'stability': serializer.toJson<double>(stability),
      'difficulty': serializer.toJson<double>(difficulty),
      'elapsedDays': serializer.toJson<int>(elapsedDays),
      'lastElapsedDays': serializer.toJson<int>(lastElapsedDays),
      'scheduledDays': serializer.toJson<int>(scheduledDays),
      'review': serializer.toJson<DateTime>(review),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  ReviewLogsLocalData copyWith({
    int? id,
    int? cardId,
    int? rating,
    int? state,
    DateTime? due,
    double? stability,
    double? difficulty,
    int? elapsedDays,
    int? lastElapsedDays,
    int? scheduledDays,
    DateTime? review,
    bool? isSynced,
  }) => ReviewLogsLocalData(
    id: id ?? this.id,
    cardId: cardId ?? this.cardId,
    rating: rating ?? this.rating,
    state: state ?? this.state,
    due: due ?? this.due,
    stability: stability ?? this.stability,
    difficulty: difficulty ?? this.difficulty,
    elapsedDays: elapsedDays ?? this.elapsedDays,
    lastElapsedDays: lastElapsedDays ?? this.lastElapsedDays,
    scheduledDays: scheduledDays ?? this.scheduledDays,
    review: review ?? this.review,
    isSynced: isSynced ?? this.isSynced,
  );
  ReviewLogsLocalData copyWithCompanion(ReviewLogsLocalCompanion data) {
    return ReviewLogsLocalData(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      rating: data.rating.present ? data.rating.value : this.rating,
      state: data.state.present ? data.state.value : this.state,
      due: data.due.present ? data.due.value : this.due,
      stability: data.stability.present ? data.stability.value : this.stability,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      elapsedDays: data.elapsedDays.present
          ? data.elapsedDays.value
          : this.elapsedDays,
      lastElapsedDays: data.lastElapsedDays.present
          ? data.lastElapsedDays.value
          : this.lastElapsedDays,
      scheduledDays: data.scheduledDays.present
          ? data.scheduledDays.value
          : this.scheduledDays,
      review: data.review.present ? data.review.value : this.review,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewLogsLocalData(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('rating: $rating, ')
          ..write('state: $state, ')
          ..write('due: $due, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('elapsedDays: $elapsedDays, ')
          ..write('lastElapsedDays: $lastElapsedDays, ')
          ..write('scheduledDays: $scheduledDays, ')
          ..write('review: $review, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cardId,
    rating,
    state,
    due,
    stability,
    difficulty,
    elapsedDays,
    lastElapsedDays,
    scheduledDays,
    review,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewLogsLocalData &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.rating == this.rating &&
          other.state == this.state &&
          other.due == this.due &&
          other.stability == this.stability &&
          other.difficulty == this.difficulty &&
          other.elapsedDays == this.elapsedDays &&
          other.lastElapsedDays == this.lastElapsedDays &&
          other.scheduledDays == this.scheduledDays &&
          other.review == this.review &&
          other.isSynced == this.isSynced);
}

class ReviewLogsLocalCompanion extends UpdateCompanion<ReviewLogsLocalData> {
  final Value<int> id;
  final Value<int> cardId;
  final Value<int> rating;
  final Value<int> state;
  final Value<DateTime> due;
  final Value<double> stability;
  final Value<double> difficulty;
  final Value<int> elapsedDays;
  final Value<int> lastElapsedDays;
  final Value<int> scheduledDays;
  final Value<DateTime> review;
  final Value<bool> isSynced;
  const ReviewLogsLocalCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.rating = const Value.absent(),
    this.state = const Value.absent(),
    this.due = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.elapsedDays = const Value.absent(),
    this.lastElapsedDays = const Value.absent(),
    this.scheduledDays = const Value.absent(),
    this.review = const Value.absent(),
    this.isSynced = const Value.absent(),
  });
  ReviewLogsLocalCompanion.insert({
    this.id = const Value.absent(),
    required int cardId,
    required int rating,
    required int state,
    required DateTime due,
    required double stability,
    required double difficulty,
    required int elapsedDays,
    required int lastElapsedDays,
    required int scheduledDays,
    required DateTime review,
    this.isSynced = const Value.absent(),
  }) : cardId = Value(cardId),
       rating = Value(rating),
       state = Value(state),
       due = Value(due),
       stability = Value(stability),
       difficulty = Value(difficulty),
       elapsedDays = Value(elapsedDays),
       lastElapsedDays = Value(lastElapsedDays),
       scheduledDays = Value(scheduledDays),
       review = Value(review);
  static Insertable<ReviewLogsLocalData> custom({
    Expression<int>? id,
    Expression<int>? cardId,
    Expression<int>? rating,
    Expression<int>? state,
    Expression<DateTime>? due,
    Expression<double>? stability,
    Expression<double>? difficulty,
    Expression<int>? elapsedDays,
    Expression<int>? lastElapsedDays,
    Expression<int>? scheduledDays,
    Expression<DateTime>? review,
    Expression<bool>? isSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (rating != null) 'rating': rating,
      if (state != null) 'state': state,
      if (due != null) 'due': due,
      if (stability != null) 'stability': stability,
      if (difficulty != null) 'difficulty': difficulty,
      if (elapsedDays != null) 'elapsed_days': elapsedDays,
      if (lastElapsedDays != null) 'last_elapsed_days': lastElapsedDays,
      if (scheduledDays != null) 'scheduled_days': scheduledDays,
      if (review != null) 'review': review,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  ReviewLogsLocalCompanion copyWith({
    Value<int>? id,
    Value<int>? cardId,
    Value<int>? rating,
    Value<int>? state,
    Value<DateTime>? due,
    Value<double>? stability,
    Value<double>? difficulty,
    Value<int>? elapsedDays,
    Value<int>? lastElapsedDays,
    Value<int>? scheduledDays,
    Value<DateTime>? review,
    Value<bool>? isSynced,
  }) {
    return ReviewLogsLocalCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      rating: rating ?? this.rating,
      state: state ?? this.state,
      due: due ?? this.due,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      elapsedDays: elapsedDays ?? this.elapsedDays,
      lastElapsedDays: lastElapsedDays ?? this.lastElapsedDays,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      review: review ?? this.review,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<int>(cardId.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (state.present) {
      map['state'] = Variable<int>(state.value);
    }
    if (due.present) {
      map['due'] = Variable<DateTime>(due.value);
    }
    if (stability.present) {
      map['stability'] = Variable<double>(stability.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<double>(difficulty.value);
    }
    if (elapsedDays.present) {
      map['elapsed_days'] = Variable<int>(elapsedDays.value);
    }
    if (lastElapsedDays.present) {
      map['last_elapsed_days'] = Variable<int>(lastElapsedDays.value);
    }
    if (scheduledDays.present) {
      map['scheduled_days'] = Variable<int>(scheduledDays.value);
    }
    if (review.present) {
      map['review'] = Variable<DateTime>(review.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewLogsLocalCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('rating: $rating, ')
          ..write('state: $state, ')
          ..write('due: $due, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('elapsedDays: $elapsedDays, ')
          ..write('lastElapsedDays: $lastElapsedDays, ')
          ..write('scheduledDays: $scheduledDays, ')
          ..write('review: $review, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }
}

class $CardsLocalTable extends CardsLocal
    with TableInfo<$CardsLocalTable, CardsLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardsLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mistakeIdMeta = const VerificationMeta(
    'mistakeId',
  );
  @override
  late final GeneratedColumn<int> mistakeId = GeneratedColumn<int>(
    'mistake_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _frontMeta = const VerificationMeta('front');
  @override
  late final GeneratedColumn<String> front = GeneratedColumn<String>(
    'front',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _backMeta = const VerificationMeta('back');
  @override
  late final GeneratedColumn<String> back = GeneratedColumn<String>(
    'back',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stabilityMeta = const VerificationMeta(
    'stability',
  );
  @override
  late final GeneratedColumn<double> stability = GeneratedColumn<double>(
    'stability',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<double> difficulty = GeneratedColumn<double>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _elapsedDaysMeta = const VerificationMeta(
    'elapsedDays',
  );
  @override
  late final GeneratedColumn<int> elapsedDays = GeneratedColumn<int>(
    'elapsed_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledDaysMeta = const VerificationMeta(
    'scheduledDays',
  );
  @override
  late final GeneratedColumn<int> scheduledDays = GeneratedColumn<int>(
    'scheduled_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lapsesMeta = const VerificationMeta('lapses');
  @override
  late final GeneratedColumn<int> lapses = GeneratedColumn<int>(
    'lapses',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<int> state = GeneratedColumn<int>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastReviewMeta = const VerificationMeta(
    'lastReview',
  );
  @override
  late final GeneratedColumn<DateTime> lastReview = GeneratedColumn<DateTime>(
    'last_review',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('interview_mistake'),
  );
  static const VerificationMeta _itemTypeMeta = const VerificationMeta(
    'itemType',
  );
  @override
  late final GeneratedColumn<String> itemType = GeneratedColumn<String>(
    'item_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('sentence_correction'),
  );
  static const VerificationMeta _unitOrPackIdMeta = const VerificationMeta(
    'unitOrPackId',
  );
  @override
  late final GeneratedColumn<String> unitOrPackId = GeneratedColumn<String>(
    'unit_or_pack_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _skillMeta = const VerificationMeta('skill');
  @override
  late final GeneratedColumn<String> skill = GeneratedColumn<String>(
    'skill',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('speaking'),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('user-ivan'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mistakeId,
    front,
    back,
    stability,
    difficulty,
    elapsedDays,
    scheduledDays,
    reps,
    lapses,
    state,
    lastReview,
    dueDate,
    updatedAt,
    sourceType,
    itemType,
    unitOrPackId,
    skill,
    userId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cards_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardsLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('mistake_id')) {
      context.handle(
        _mistakeIdMeta,
        mistakeId.isAcceptableOrUnknown(data['mistake_id']!, _mistakeIdMeta),
      );
    }
    if (data.containsKey('front')) {
      context.handle(
        _frontMeta,
        front.isAcceptableOrUnknown(data['front']!, _frontMeta),
      );
    } else if (isInserting) {
      context.missing(_frontMeta);
    }
    if (data.containsKey('back')) {
      context.handle(
        _backMeta,
        back.isAcceptableOrUnknown(data['back']!, _backMeta),
      );
    } else if (isInserting) {
      context.missing(_backMeta);
    }
    if (data.containsKey('stability')) {
      context.handle(
        _stabilityMeta,
        stability.isAcceptableOrUnknown(data['stability']!, _stabilityMeta),
      );
    } else if (isInserting) {
      context.missing(_stabilityMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    } else if (isInserting) {
      context.missing(_difficultyMeta);
    }
    if (data.containsKey('elapsed_days')) {
      context.handle(
        _elapsedDaysMeta,
        elapsedDays.isAcceptableOrUnknown(
          data['elapsed_days']!,
          _elapsedDaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_elapsedDaysMeta);
    }
    if (data.containsKey('scheduled_days')) {
      context.handle(
        _scheduledDaysMeta,
        scheduledDays.isAcceptableOrUnknown(
          data['scheduled_days']!,
          _scheduledDaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledDaysMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    } else if (isInserting) {
      context.missing(_repsMeta);
    }
    if (data.containsKey('lapses')) {
      context.handle(
        _lapsesMeta,
        lapses.isAcceptableOrUnknown(data['lapses']!, _lapsesMeta),
      );
    } else if (isInserting) {
      context.missing(_lapsesMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('last_review')) {
      context.handle(
        _lastReviewMeta,
        lastReview.isAcceptableOrUnknown(data['last_review']!, _lastReviewMeta),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    }
    if (data.containsKey('item_type')) {
      context.handle(
        _itemTypeMeta,
        itemType.isAcceptableOrUnknown(data['item_type']!, _itemTypeMeta),
      );
    }
    if (data.containsKey('unit_or_pack_id')) {
      context.handle(
        _unitOrPackIdMeta,
        unitOrPackId.isAcceptableOrUnknown(
          data['unit_or_pack_id']!,
          _unitOrPackIdMeta,
        ),
      );
    }
    if (data.containsKey('skill')) {
      context.handle(
        _skillMeta,
        skill.isAcceptableOrUnknown(data['skill']!, _skillMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardsLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardsLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      mistakeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mistake_id'],
      ),
      front: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}front'],
      )!,
      back: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}back'],
      )!,
      stability: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stability'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}difficulty'],
      )!,
      elapsedDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_days'],
      )!,
      scheduledDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scheduled_days'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      lapses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lapses'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}state'],
      )!,
      lastReview: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_review'],
      ),
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
      itemType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_type'],
      )!,
      unitOrPackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_or_pack_id'],
      ),
      skill: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}skill'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
    );
  }

  @override
  $CardsLocalTable createAlias(String alias) {
    return $CardsLocalTable(attachedDatabase, alias);
  }
}

class CardsLocalData extends DataClass implements Insertable<CardsLocalData> {
  final int id;
  final int? mistakeId;
  final String front;
  final String back;
  final double stability;
  final double difficulty;
  final int elapsedDays;
  final int scheduledDays;
  final int reps;
  final int lapses;
  final int state;
  final DateTime? lastReview;
  final DateTime dueDate;
  final DateTime updatedAt;
  final String sourceType;
  final String itemType;
  final String? unitOrPackId;
  final String skill;
  final String userId;
  const CardsLocalData({
    required this.id,
    this.mistakeId,
    required this.front,
    required this.back,
    required this.stability,
    required this.difficulty,
    required this.elapsedDays,
    required this.scheduledDays,
    required this.reps,
    required this.lapses,
    required this.state,
    this.lastReview,
    required this.dueDate,
    required this.updatedAt,
    required this.sourceType,
    required this.itemType,
    this.unitOrPackId,
    required this.skill,
    required this.userId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || mistakeId != null) {
      map['mistake_id'] = Variable<int>(mistakeId);
    }
    map['front'] = Variable<String>(front);
    map['back'] = Variable<String>(back);
    map['stability'] = Variable<double>(stability);
    map['difficulty'] = Variable<double>(difficulty);
    map['elapsed_days'] = Variable<int>(elapsedDays);
    map['scheduled_days'] = Variable<int>(scheduledDays);
    map['reps'] = Variable<int>(reps);
    map['lapses'] = Variable<int>(lapses);
    map['state'] = Variable<int>(state);
    if (!nullToAbsent || lastReview != null) {
      map['last_review'] = Variable<DateTime>(lastReview);
    }
    map['due_date'] = Variable<DateTime>(dueDate);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['source_type'] = Variable<String>(sourceType);
    map['item_type'] = Variable<String>(itemType);
    if (!nullToAbsent || unitOrPackId != null) {
      map['unit_or_pack_id'] = Variable<String>(unitOrPackId);
    }
    map['skill'] = Variable<String>(skill);
    map['user_id'] = Variable<String>(userId);
    return map;
  }

  CardsLocalCompanion toCompanion(bool nullToAbsent) {
    return CardsLocalCompanion(
      id: Value(id),
      mistakeId: mistakeId == null && nullToAbsent
          ? const Value.absent()
          : Value(mistakeId),
      front: Value(front),
      back: Value(back),
      stability: Value(stability),
      difficulty: Value(difficulty),
      elapsedDays: Value(elapsedDays),
      scheduledDays: Value(scheduledDays),
      reps: Value(reps),
      lapses: Value(lapses),
      state: Value(state),
      lastReview: lastReview == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReview),
      dueDate: Value(dueDate),
      updatedAt: Value(updatedAt),
      sourceType: Value(sourceType),
      itemType: Value(itemType),
      unitOrPackId: unitOrPackId == null && nullToAbsent
          ? const Value.absent()
          : Value(unitOrPackId),
      skill: Value(skill),
      userId: Value(userId),
    );
  }

  factory CardsLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardsLocalData(
      id: serializer.fromJson<int>(json['id']),
      mistakeId: serializer.fromJson<int?>(json['mistakeId']),
      front: serializer.fromJson<String>(json['front']),
      back: serializer.fromJson<String>(json['back']),
      stability: serializer.fromJson<double>(json['stability']),
      difficulty: serializer.fromJson<double>(json['difficulty']),
      elapsedDays: serializer.fromJson<int>(json['elapsedDays']),
      scheduledDays: serializer.fromJson<int>(json['scheduledDays']),
      reps: serializer.fromJson<int>(json['reps']),
      lapses: serializer.fromJson<int>(json['lapses']),
      state: serializer.fromJson<int>(json['state']),
      lastReview: serializer.fromJson<DateTime?>(json['lastReview']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      itemType: serializer.fromJson<String>(json['itemType']),
      unitOrPackId: serializer.fromJson<String?>(json['unitOrPackId']),
      skill: serializer.fromJson<String>(json['skill']),
      userId: serializer.fromJson<String>(json['userId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mistakeId': serializer.toJson<int?>(mistakeId),
      'front': serializer.toJson<String>(front),
      'back': serializer.toJson<String>(back),
      'stability': serializer.toJson<double>(stability),
      'difficulty': serializer.toJson<double>(difficulty),
      'elapsedDays': serializer.toJson<int>(elapsedDays),
      'scheduledDays': serializer.toJson<int>(scheduledDays),
      'reps': serializer.toJson<int>(reps),
      'lapses': serializer.toJson<int>(lapses),
      'state': serializer.toJson<int>(state),
      'lastReview': serializer.toJson<DateTime?>(lastReview),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'sourceType': serializer.toJson<String>(sourceType),
      'itemType': serializer.toJson<String>(itemType),
      'unitOrPackId': serializer.toJson<String?>(unitOrPackId),
      'skill': serializer.toJson<String>(skill),
      'userId': serializer.toJson<String>(userId),
    };
  }

  CardsLocalData copyWith({
    int? id,
    Value<int?> mistakeId = const Value.absent(),
    String? front,
    String? back,
    double? stability,
    double? difficulty,
    int? elapsedDays,
    int? scheduledDays,
    int? reps,
    int? lapses,
    int? state,
    Value<DateTime?> lastReview = const Value.absent(),
    DateTime? dueDate,
    DateTime? updatedAt,
    String? sourceType,
    String? itemType,
    Value<String?> unitOrPackId = const Value.absent(),
    String? skill,
    String? userId,
  }) => CardsLocalData(
    id: id ?? this.id,
    mistakeId: mistakeId.present ? mistakeId.value : this.mistakeId,
    front: front ?? this.front,
    back: back ?? this.back,
    stability: stability ?? this.stability,
    difficulty: difficulty ?? this.difficulty,
    elapsedDays: elapsedDays ?? this.elapsedDays,
    scheduledDays: scheduledDays ?? this.scheduledDays,
    reps: reps ?? this.reps,
    lapses: lapses ?? this.lapses,
    state: state ?? this.state,
    lastReview: lastReview.present ? lastReview.value : this.lastReview,
    dueDate: dueDate ?? this.dueDate,
    updatedAt: updatedAt ?? this.updatedAt,
    sourceType: sourceType ?? this.sourceType,
    itemType: itemType ?? this.itemType,
    unitOrPackId: unitOrPackId.present ? unitOrPackId.value : this.unitOrPackId,
    skill: skill ?? this.skill,
    userId: userId ?? this.userId,
  );
  CardsLocalData copyWithCompanion(CardsLocalCompanion data) {
    return CardsLocalData(
      id: data.id.present ? data.id.value : this.id,
      mistakeId: data.mistakeId.present ? data.mistakeId.value : this.mistakeId,
      front: data.front.present ? data.front.value : this.front,
      back: data.back.present ? data.back.value : this.back,
      stability: data.stability.present ? data.stability.value : this.stability,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      elapsedDays: data.elapsedDays.present
          ? data.elapsedDays.value
          : this.elapsedDays,
      scheduledDays: data.scheduledDays.present
          ? data.scheduledDays.value
          : this.scheduledDays,
      reps: data.reps.present ? data.reps.value : this.reps,
      lapses: data.lapses.present ? data.lapses.value : this.lapses,
      state: data.state.present ? data.state.value : this.state,
      lastReview: data.lastReview.present
          ? data.lastReview.value
          : this.lastReview,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      itemType: data.itemType.present ? data.itemType.value : this.itemType,
      unitOrPackId: data.unitOrPackId.present
          ? data.unitOrPackId.value
          : this.unitOrPackId,
      skill: data.skill.present ? data.skill.value : this.skill,
      userId: data.userId.present ? data.userId.value : this.userId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardsLocalData(')
          ..write('id: $id, ')
          ..write('mistakeId: $mistakeId, ')
          ..write('front: $front, ')
          ..write('back: $back, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('elapsedDays: $elapsedDays, ')
          ..write('scheduledDays: $scheduledDays, ')
          ..write('reps: $reps, ')
          ..write('lapses: $lapses, ')
          ..write('state: $state, ')
          ..write('lastReview: $lastReview, ')
          ..write('dueDate: $dueDate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sourceType: $sourceType, ')
          ..write('itemType: $itemType, ')
          ..write('unitOrPackId: $unitOrPackId, ')
          ..write('skill: $skill, ')
          ..write('userId: $userId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mistakeId,
    front,
    back,
    stability,
    difficulty,
    elapsedDays,
    scheduledDays,
    reps,
    lapses,
    state,
    lastReview,
    dueDate,
    updatedAt,
    sourceType,
    itemType,
    unitOrPackId,
    skill,
    userId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardsLocalData &&
          other.id == this.id &&
          other.mistakeId == this.mistakeId &&
          other.front == this.front &&
          other.back == this.back &&
          other.stability == this.stability &&
          other.difficulty == this.difficulty &&
          other.elapsedDays == this.elapsedDays &&
          other.scheduledDays == this.scheduledDays &&
          other.reps == this.reps &&
          other.lapses == this.lapses &&
          other.state == this.state &&
          other.lastReview == this.lastReview &&
          other.dueDate == this.dueDate &&
          other.updatedAt == this.updatedAt &&
          other.sourceType == this.sourceType &&
          other.itemType == this.itemType &&
          other.unitOrPackId == this.unitOrPackId &&
          other.skill == this.skill &&
          other.userId == this.userId);
}

class CardsLocalCompanion extends UpdateCompanion<CardsLocalData> {
  final Value<int> id;
  final Value<int?> mistakeId;
  final Value<String> front;
  final Value<String> back;
  final Value<double> stability;
  final Value<double> difficulty;
  final Value<int> elapsedDays;
  final Value<int> scheduledDays;
  final Value<int> reps;
  final Value<int> lapses;
  final Value<int> state;
  final Value<DateTime?> lastReview;
  final Value<DateTime> dueDate;
  final Value<DateTime> updatedAt;
  final Value<String> sourceType;
  final Value<String> itemType;
  final Value<String?> unitOrPackId;
  final Value<String> skill;
  final Value<String> userId;
  const CardsLocalCompanion({
    this.id = const Value.absent(),
    this.mistakeId = const Value.absent(),
    this.front = const Value.absent(),
    this.back = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.elapsedDays = const Value.absent(),
    this.scheduledDays = const Value.absent(),
    this.reps = const Value.absent(),
    this.lapses = const Value.absent(),
    this.state = const Value.absent(),
    this.lastReview = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.itemType = const Value.absent(),
    this.unitOrPackId = const Value.absent(),
    this.skill = const Value.absent(),
    this.userId = const Value.absent(),
  });
  CardsLocalCompanion.insert({
    this.id = const Value.absent(),
    this.mistakeId = const Value.absent(),
    required String front,
    required String back,
    required double stability,
    required double difficulty,
    required int elapsedDays,
    required int scheduledDays,
    required int reps,
    required int lapses,
    required int state,
    this.lastReview = const Value.absent(),
    required DateTime dueDate,
    required DateTime updatedAt,
    this.sourceType = const Value.absent(),
    this.itemType = const Value.absent(),
    this.unitOrPackId = const Value.absent(),
    this.skill = const Value.absent(),
    this.userId = const Value.absent(),
  }) : front = Value(front),
       back = Value(back),
       stability = Value(stability),
       difficulty = Value(difficulty),
       elapsedDays = Value(elapsedDays),
       scheduledDays = Value(scheduledDays),
       reps = Value(reps),
       lapses = Value(lapses),
       state = Value(state),
       dueDate = Value(dueDate),
       updatedAt = Value(updatedAt);
  static Insertable<CardsLocalData> custom({
    Expression<int>? id,
    Expression<int>? mistakeId,
    Expression<String>? front,
    Expression<String>? back,
    Expression<double>? stability,
    Expression<double>? difficulty,
    Expression<int>? elapsedDays,
    Expression<int>? scheduledDays,
    Expression<int>? reps,
    Expression<int>? lapses,
    Expression<int>? state,
    Expression<DateTime>? lastReview,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? updatedAt,
    Expression<String>? sourceType,
    Expression<String>? itemType,
    Expression<String>? unitOrPackId,
    Expression<String>? skill,
    Expression<String>? userId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mistakeId != null) 'mistake_id': mistakeId,
      if (front != null) 'front': front,
      if (back != null) 'back': back,
      if (stability != null) 'stability': stability,
      if (difficulty != null) 'difficulty': difficulty,
      if (elapsedDays != null) 'elapsed_days': elapsedDays,
      if (scheduledDays != null) 'scheduled_days': scheduledDays,
      if (reps != null) 'reps': reps,
      if (lapses != null) 'lapses': lapses,
      if (state != null) 'state': state,
      if (lastReview != null) 'last_review': lastReview,
      if (dueDate != null) 'due_date': dueDate,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (sourceType != null) 'source_type': sourceType,
      if (itemType != null) 'item_type': itemType,
      if (unitOrPackId != null) 'unit_or_pack_id': unitOrPackId,
      if (skill != null) 'skill': skill,
      if (userId != null) 'user_id': userId,
    });
  }

  CardsLocalCompanion copyWith({
    Value<int>? id,
    Value<int?>? mistakeId,
    Value<String>? front,
    Value<String>? back,
    Value<double>? stability,
    Value<double>? difficulty,
    Value<int>? elapsedDays,
    Value<int>? scheduledDays,
    Value<int>? reps,
    Value<int>? lapses,
    Value<int>? state,
    Value<DateTime?>? lastReview,
    Value<DateTime>? dueDate,
    Value<DateTime>? updatedAt,
    Value<String>? sourceType,
    Value<String>? itemType,
    Value<String?>? unitOrPackId,
    Value<String>? skill,
    Value<String>? userId,
  }) {
    return CardsLocalCompanion(
      id: id ?? this.id,
      mistakeId: mistakeId ?? this.mistakeId,
      front: front ?? this.front,
      back: back ?? this.back,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      elapsedDays: elapsedDays ?? this.elapsedDays,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      state: state ?? this.state,
      lastReview: lastReview ?? this.lastReview,
      dueDate: dueDate ?? this.dueDate,
      updatedAt: updatedAt ?? this.updatedAt,
      sourceType: sourceType ?? this.sourceType,
      itemType: itemType ?? this.itemType,
      unitOrPackId: unitOrPackId ?? this.unitOrPackId,
      skill: skill ?? this.skill,
      userId: userId ?? this.userId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mistakeId.present) {
      map['mistake_id'] = Variable<int>(mistakeId.value);
    }
    if (front.present) {
      map['front'] = Variable<String>(front.value);
    }
    if (back.present) {
      map['back'] = Variable<String>(back.value);
    }
    if (stability.present) {
      map['stability'] = Variable<double>(stability.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<double>(difficulty.value);
    }
    if (elapsedDays.present) {
      map['elapsed_days'] = Variable<int>(elapsedDays.value);
    }
    if (scheduledDays.present) {
      map['scheduled_days'] = Variable<int>(scheduledDays.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (lapses.present) {
      map['lapses'] = Variable<int>(lapses.value);
    }
    if (state.present) {
      map['state'] = Variable<int>(state.value);
    }
    if (lastReview.present) {
      map['last_review'] = Variable<DateTime>(lastReview.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (itemType.present) {
      map['item_type'] = Variable<String>(itemType.value);
    }
    if (unitOrPackId.present) {
      map['unit_or_pack_id'] = Variable<String>(unitOrPackId.value);
    }
    if (skill.present) {
      map['skill'] = Variable<String>(skill.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardsLocalCompanion(')
          ..write('id: $id, ')
          ..write('mistakeId: $mistakeId, ')
          ..write('front: $front, ')
          ..write('back: $back, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('elapsedDays: $elapsedDays, ')
          ..write('scheduledDays: $scheduledDays, ')
          ..write('reps: $reps, ')
          ..write('lapses: $lapses, ')
          ..write('state: $state, ')
          ..write('lastReview: $lastReview, ')
          ..write('dueDate: $dueDate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sourceType: $sourceType, ')
          ..write('itemType: $itemType, ')
          ..write('unitOrPackId: $unitOrPackId, ')
          ..write('skill: $skill, ')
          ..write('userId: $userId')
          ..write(')'))
        .toString();
  }
}

class $QueueItemsTable extends QueueItems
    with TableInfo<$QueueItemsTable, QueueItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QueueItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<int> questionId = GeneratedColumn<int>(
    'question_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioPathMeta = const VerificationMeta(
    'audioPath',
  );
  @override
  late final GeneratedColumn<String> audioPath = GeneratedColumn<String>(
    'audio_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    questionId,
    audioPath,
    createdAt,
    retryCount,
    lastError,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'queue_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<QueueItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    }
    if (data.containsKey('audio_path')) {
      context.handle(
        _audioPathMeta,
        audioPath.isAcceptableOrUnknown(data['audio_path']!, _audioPathMeta),
      );
    } else if (isInserting) {
      context.missing(_audioPathMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QueueItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QueueItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}question_id'],
      ),
      audioPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_path'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $QueueItemsTable createAlias(String alias) {
    return $QueueItemsTable(attachedDatabase, alias);
  }
}

class QueueItem extends DataClass implements Insertable<QueueItem> {
  final String id;
  final String sessionId;
  final int? questionId;
  final String audioPath;
  final DateTime createdAt;
  final int retryCount;
  final String? lastError;
  final String status;
  const QueueItem({
    required this.id,
    required this.sessionId,
    this.questionId,
    required this.audioPath,
    required this.createdAt,
    required this.retryCount,
    this.lastError,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    if (!nullToAbsent || questionId != null) {
      map['question_id'] = Variable<int>(questionId);
    }
    map['audio_path'] = Variable<String>(audioPath);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  QueueItemsCompanion toCompanion(bool nullToAbsent) {
    return QueueItemsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      questionId: questionId == null && nullToAbsent
          ? const Value.absent()
          : Value(questionId),
      audioPath: Value(audioPath),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      status: Value(status),
    );
  }

  factory QueueItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QueueItem(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      questionId: serializer.fromJson<int?>(json['questionId']),
      audioPath: serializer.fromJson<String>(json['audioPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'questionId': serializer.toJson<int?>(questionId),
      'audioPath': serializer.toJson<String>(audioPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
      'status': serializer.toJson<String>(status),
    };
  }

  QueueItem copyWith({
    String? id,
    String? sessionId,
    Value<int?> questionId = const Value.absent(),
    String? audioPath,
    DateTime? createdAt,
    int? retryCount,
    Value<String?> lastError = const Value.absent(),
    String? status,
  }) => QueueItem(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    questionId: questionId.present ? questionId.value : this.questionId,
    audioPath: audioPath ?? this.audioPath,
    createdAt: createdAt ?? this.createdAt,
    retryCount: retryCount ?? this.retryCount,
    lastError: lastError.present ? lastError.value : this.lastError,
    status: status ?? this.status,
  );
  QueueItem copyWithCompanion(QueueItemsCompanion data) {
    return QueueItem(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      audioPath: data.audioPath.present ? data.audioPath.value : this.audioPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QueueItem(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('questionId: $questionId, ')
          ..write('audioPath: $audioPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    questionId,
    audioPath,
    createdAt,
    retryCount,
    lastError,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueueItem &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.questionId == this.questionId &&
          other.audioPath == this.audioPath &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError &&
          other.status == this.status);
}

class QueueItemsCompanion extends UpdateCompanion<QueueItem> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<int?> questionId;
  final Value<String> audioPath;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  final Value<String?> lastError;
  final Value<String> status;
  final Value<int> rowid;
  const QueueItemsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QueueItemsCompanion.insert({
    required String id,
    required String sessionId,
    this.questionId = const Value.absent(),
    required String audioPath,
    required DateTime createdAt,
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       audioPath = Value(audioPath),
       createdAt = Value(createdAt);
  static Insertable<QueueItem> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<int>? questionId,
    Expression<String>? audioPath,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
    Expression<String>? lastError,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (questionId != null) 'question_id': questionId,
      if (audioPath != null) 'audio_path': audioPath,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QueueItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<int?>? questionId,
    Value<String>? audioPath,
    Value<DateTime>? createdAt,
    Value<int>? retryCount,
    Value<String?>? lastError,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return QueueItemsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      questionId: questionId ?? this.questionId,
      audioPath: audioPath ?? this.audioPath,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<int>(questionId.value);
    }
    if (audioPath.present) {
      map['audio_path'] = Variable<String>(audioPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QueueItemsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('questionId: $questionId, ')
          ..write('audioPath: $audioPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JournalEntriesTable extends JournalEntries
    with TableInfo<$JournalEntriesTable, JournalEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionsCountMeta = const VerificationMeta(
    'questionsCount',
  );
  @override
  late final GeneratedColumn<int> questionsCount = GeneratedColumn<int>(
    'questions_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _overallScoreMeta = const VerificationMeta(
    'overallScore',
  );
  @override
  late final GeneratedColumn<double> overallScore = GeneratedColumn<double>(
    'overall_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mistakesCountMeta = const VerificationMeta(
    'mistakesCount',
  );
  @override
  late final GeneratedColumn<int> mistakesCount = GeneratedColumn<int>(
    'mistakes_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mistakesJsonMeta = const VerificationMeta(
    'mistakesJson',
  );
  @override
  late final GeneratedColumn<String> mistakesJson = GeneratedColumn<String>(
    'mistakes_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vocabularyJsonMeta = const VerificationMeta(
    'vocabularyJson',
  );
  @override
  late final GeneratedColumn<String> vocabularyJson = GeneratedColumn<String>(
    'vocabulary_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _markdownContentMeta = const VerificationMeta(
    'markdownContent',
  );
  @override
  late final GeneratedColumn<String> markdownContent = GeneratedColumn<String>(
    'markdown_content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isExportedMeta = const VerificationMeta(
    'isExported',
  );
  @override
  late final GeneratedColumn<bool> isExported = GeneratedColumn<bool>(
    'is_exported',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_exported" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    title,
    date,
    durationSeconds,
    questionsCount,
    overallScore,
    mistakesCount,
    mistakesJson,
    vocabularyJson,
    markdownContent,
    isExported,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<JournalEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('questions_count')) {
      context.handle(
        _questionsCountMeta,
        questionsCount.isAcceptableOrUnknown(
          data['questions_count']!,
          _questionsCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_questionsCountMeta);
    }
    if (data.containsKey('overall_score')) {
      context.handle(
        _overallScoreMeta,
        overallScore.isAcceptableOrUnknown(
          data['overall_score']!,
          _overallScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_overallScoreMeta);
    }
    if (data.containsKey('mistakes_count')) {
      context.handle(
        _mistakesCountMeta,
        mistakesCount.isAcceptableOrUnknown(
          data['mistakes_count']!,
          _mistakesCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mistakesCountMeta);
    }
    if (data.containsKey('mistakes_json')) {
      context.handle(
        _mistakesJsonMeta,
        mistakesJson.isAcceptableOrUnknown(
          data['mistakes_json']!,
          _mistakesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mistakesJsonMeta);
    }
    if (data.containsKey('vocabulary_json')) {
      context.handle(
        _vocabularyJsonMeta,
        vocabularyJson.isAcceptableOrUnknown(
          data['vocabulary_json']!,
          _vocabularyJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vocabularyJsonMeta);
    }
    if (data.containsKey('markdown_content')) {
      context.handle(
        _markdownContentMeta,
        markdownContent.isAcceptableOrUnknown(
          data['markdown_content']!,
          _markdownContentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_markdownContentMeta);
    }
    if (data.containsKey('is_exported')) {
      context.handle(
        _isExportedMeta,
        isExported.isAcceptableOrUnknown(data['is_exported']!, _isExportedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JournalEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      questionsCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}questions_count'],
      )!,
      overallScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}overall_score'],
      )!,
      mistakesCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mistakes_count'],
      )!,
      mistakesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mistakes_json'],
      )!,
      vocabularyJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vocabulary_json'],
      )!,
      markdownContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}markdown_content'],
      )!,
      isExported: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_exported'],
      )!,
    );
  }

  @override
  $JournalEntriesTable createAlias(String alias) {
    return $JournalEntriesTable(attachedDatabase, alias);
  }
}

class JournalEntry extends DataClass implements Insertable<JournalEntry> {
  final String id;
  final String sessionId;
  final String title;
  final DateTime date;
  final int durationSeconds;
  final int questionsCount;
  final double overallScore;
  final int mistakesCount;
  final String mistakesJson;
  final String vocabularyJson;
  final String markdownContent;
  final bool isExported;
  const JournalEntry({
    required this.id,
    required this.sessionId,
    required this.title,
    required this.date,
    required this.durationSeconds,
    required this.questionsCount,
    required this.overallScore,
    required this.mistakesCount,
    required this.mistakesJson,
    required this.vocabularyJson,
    required this.markdownContent,
    required this.isExported,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['title'] = Variable<String>(title);
    map['date'] = Variable<DateTime>(date);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['questions_count'] = Variable<int>(questionsCount);
    map['overall_score'] = Variable<double>(overallScore);
    map['mistakes_count'] = Variable<int>(mistakesCount);
    map['mistakes_json'] = Variable<String>(mistakesJson);
    map['vocabulary_json'] = Variable<String>(vocabularyJson);
    map['markdown_content'] = Variable<String>(markdownContent);
    map['is_exported'] = Variable<bool>(isExported);
    return map;
  }

  JournalEntriesCompanion toCompanion(bool nullToAbsent) {
    return JournalEntriesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      title: Value(title),
      date: Value(date),
      durationSeconds: Value(durationSeconds),
      questionsCount: Value(questionsCount),
      overallScore: Value(overallScore),
      mistakesCount: Value(mistakesCount),
      mistakesJson: Value(mistakesJson),
      vocabularyJson: Value(vocabularyJson),
      markdownContent: Value(markdownContent),
      isExported: Value(isExported),
    );
  }

  factory JournalEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalEntry(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      title: serializer.fromJson<String>(json['title']),
      date: serializer.fromJson<DateTime>(json['date']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      questionsCount: serializer.fromJson<int>(json['questionsCount']),
      overallScore: serializer.fromJson<double>(json['overallScore']),
      mistakesCount: serializer.fromJson<int>(json['mistakesCount']),
      mistakesJson: serializer.fromJson<String>(json['mistakesJson']),
      vocabularyJson: serializer.fromJson<String>(json['vocabularyJson']),
      markdownContent: serializer.fromJson<String>(json['markdownContent']),
      isExported: serializer.fromJson<bool>(json['isExported']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'title': serializer.toJson<String>(title),
      'date': serializer.toJson<DateTime>(date),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'questionsCount': serializer.toJson<int>(questionsCount),
      'overallScore': serializer.toJson<double>(overallScore),
      'mistakesCount': serializer.toJson<int>(mistakesCount),
      'mistakesJson': serializer.toJson<String>(mistakesJson),
      'vocabularyJson': serializer.toJson<String>(vocabularyJson),
      'markdownContent': serializer.toJson<String>(markdownContent),
      'isExported': serializer.toJson<bool>(isExported),
    };
  }

  JournalEntry copyWith({
    String? id,
    String? sessionId,
    String? title,
    DateTime? date,
    int? durationSeconds,
    int? questionsCount,
    double? overallScore,
    int? mistakesCount,
    String? mistakesJson,
    String? vocabularyJson,
    String? markdownContent,
    bool? isExported,
  }) => JournalEntry(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    title: title ?? this.title,
    date: date ?? this.date,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    questionsCount: questionsCount ?? this.questionsCount,
    overallScore: overallScore ?? this.overallScore,
    mistakesCount: mistakesCount ?? this.mistakesCount,
    mistakesJson: mistakesJson ?? this.mistakesJson,
    vocabularyJson: vocabularyJson ?? this.vocabularyJson,
    markdownContent: markdownContent ?? this.markdownContent,
    isExported: isExported ?? this.isExported,
  );
  JournalEntry copyWithCompanion(JournalEntriesCompanion data) {
    return JournalEntry(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      title: data.title.present ? data.title.value : this.title,
      date: data.date.present ? data.date.value : this.date,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      questionsCount: data.questionsCount.present
          ? data.questionsCount.value
          : this.questionsCount,
      overallScore: data.overallScore.present
          ? data.overallScore.value
          : this.overallScore,
      mistakesCount: data.mistakesCount.present
          ? data.mistakesCount.value
          : this.mistakesCount,
      mistakesJson: data.mistakesJson.present
          ? data.mistakesJson.value
          : this.mistakesJson,
      vocabularyJson: data.vocabularyJson.present
          ? data.vocabularyJson.value
          : this.vocabularyJson,
      markdownContent: data.markdownContent.present
          ? data.markdownContent.value
          : this.markdownContent,
      isExported: data.isExported.present
          ? data.isExported.value
          : this.isExported,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntry(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('questionsCount: $questionsCount, ')
          ..write('overallScore: $overallScore, ')
          ..write('mistakesCount: $mistakesCount, ')
          ..write('mistakesJson: $mistakesJson, ')
          ..write('vocabularyJson: $vocabularyJson, ')
          ..write('markdownContent: $markdownContent, ')
          ..write('isExported: $isExported')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    title,
    date,
    durationSeconds,
    questionsCount,
    overallScore,
    mistakesCount,
    mistakesJson,
    vocabularyJson,
    markdownContent,
    isExported,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalEntry &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.title == this.title &&
          other.date == this.date &&
          other.durationSeconds == this.durationSeconds &&
          other.questionsCount == this.questionsCount &&
          other.overallScore == this.overallScore &&
          other.mistakesCount == this.mistakesCount &&
          other.mistakesJson == this.mistakesJson &&
          other.vocabularyJson == this.vocabularyJson &&
          other.markdownContent == this.markdownContent &&
          other.isExported == this.isExported);
}

class JournalEntriesCompanion extends UpdateCompanion<JournalEntry> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> title;
  final Value<DateTime> date;
  final Value<int> durationSeconds;
  final Value<int> questionsCount;
  final Value<double> overallScore;
  final Value<int> mistakesCount;
  final Value<String> mistakesJson;
  final Value<String> vocabularyJson;
  final Value<String> markdownContent;
  final Value<bool> isExported;
  final Value<int> rowid;
  const JournalEntriesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.title = const Value.absent(),
    this.date = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.questionsCount = const Value.absent(),
    this.overallScore = const Value.absent(),
    this.mistakesCount = const Value.absent(),
    this.mistakesJson = const Value.absent(),
    this.vocabularyJson = const Value.absent(),
    this.markdownContent = const Value.absent(),
    this.isExported = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JournalEntriesCompanion.insert({
    required String id,
    required String sessionId,
    required String title,
    required DateTime date,
    required int durationSeconds,
    required int questionsCount,
    required double overallScore,
    required int mistakesCount,
    required String mistakesJson,
    required String vocabularyJson,
    required String markdownContent,
    this.isExported = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       title = Value(title),
       date = Value(date),
       durationSeconds = Value(durationSeconds),
       questionsCount = Value(questionsCount),
       overallScore = Value(overallScore),
       mistakesCount = Value(mistakesCount),
       mistakesJson = Value(mistakesJson),
       vocabularyJson = Value(vocabularyJson),
       markdownContent = Value(markdownContent);
  static Insertable<JournalEntry> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? title,
    Expression<DateTime>? date,
    Expression<int>? durationSeconds,
    Expression<int>? questionsCount,
    Expression<double>? overallScore,
    Expression<int>? mistakesCount,
    Expression<String>? mistakesJson,
    Expression<String>? vocabularyJson,
    Expression<String>? markdownContent,
    Expression<bool>? isExported,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (title != null) 'title': title,
      if (date != null) 'date': date,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (questionsCount != null) 'questions_count': questionsCount,
      if (overallScore != null) 'overall_score': overallScore,
      if (mistakesCount != null) 'mistakes_count': mistakesCount,
      if (mistakesJson != null) 'mistakes_json': mistakesJson,
      if (vocabularyJson != null) 'vocabulary_json': vocabularyJson,
      if (markdownContent != null) 'markdown_content': markdownContent,
      if (isExported != null) 'is_exported': isExported,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JournalEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? title,
    Value<DateTime>? date,
    Value<int>? durationSeconds,
    Value<int>? questionsCount,
    Value<double>? overallScore,
    Value<int>? mistakesCount,
    Value<String>? mistakesJson,
    Value<String>? vocabularyJson,
    Value<String>? markdownContent,
    Value<bool>? isExported,
    Value<int>? rowid,
  }) {
    return JournalEntriesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      title: title ?? this.title,
      date: date ?? this.date,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      questionsCount: questionsCount ?? this.questionsCount,
      overallScore: overallScore ?? this.overallScore,
      mistakesCount: mistakesCount ?? this.mistakesCount,
      mistakesJson: mistakesJson ?? this.mistakesJson,
      vocabularyJson: vocabularyJson ?? this.vocabularyJson,
      markdownContent: markdownContent ?? this.markdownContent,
      isExported: isExported ?? this.isExported,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (questionsCount.present) {
      map['questions_count'] = Variable<int>(questionsCount.value);
    }
    if (overallScore.present) {
      map['overall_score'] = Variable<double>(overallScore.value);
    }
    if (mistakesCount.present) {
      map['mistakes_count'] = Variable<int>(mistakesCount.value);
    }
    if (mistakesJson.present) {
      map['mistakes_json'] = Variable<String>(mistakesJson.value);
    }
    if (vocabularyJson.present) {
      map['vocabulary_json'] = Variable<String>(vocabularyJson.value);
    }
    if (markdownContent.present) {
      map['markdown_content'] = Variable<String>(markdownContent.value);
    }
    if (isExported.present) {
      map['is_exported'] = Variable<bool>(isExported.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntriesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('questionsCount: $questionsCount, ')
          ..write('overallScore: $overallScore, ')
          ..write('mistakesCount: $mistakesCount, ')
          ..write('mistakesJson: $mistakesJson, ')
          ..write('vocabularyJson: $vocabularyJson, ')
          ..write('markdownContent: $markdownContent, ')
          ..write('isExported: $isExported, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserMilestonesLocalTable extends UserMilestonesLocal
    with TableInfo<$UserMilestonesLocalTable, UserMilestonesLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserMilestonesLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _achievedMeta = const VerificationMeta(
    'achieved',
  );
  @override
  late final GeneratedColumn<bool> achieved = GeneratedColumn<bool>(
    'achieved',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("achieved" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _achievedAtMeta = const VerificationMeta(
    'achievedAt',
  );
  @override
  late final GeneratedColumn<DateTime> achievedAt = GeneratedColumn<DateTime>(
    'achieved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    achieved,
    achievedAt,
    value,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_milestones_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserMilestonesLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('achieved')) {
      context.handle(
        _achievedMeta,
        achieved.isAcceptableOrUnknown(data['achieved']!, _achievedMeta),
      );
    }
    if (data.containsKey('achieved_at')) {
      context.handle(
        _achievedAtMeta,
        achievedAt.isAcceptableOrUnknown(data['achieved_at']!, _achievedAtMeta),
      );
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserMilestonesLocalData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserMilestonesLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      achieved: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}achieved'],
      )!,
      achievedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}achieved_at'],
      ),
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
    );
  }

  @override
  $UserMilestonesLocalTable createAlias(String alias) {
    return $UserMilestonesLocalTable(attachedDatabase, alias);
  }
}

class UserMilestonesLocalData extends DataClass
    implements Insertable<UserMilestonesLocalData> {
  final String id;
  final String title;
  final String description;
  final bool achieved;
  final DateTime? achievedAt;
  final String? value;
  const UserMilestonesLocalData({
    required this.id,
    required this.title,
    required this.description,
    required this.achieved,
    this.achievedAt,
    this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['achieved'] = Variable<bool>(achieved);
    if (!nullToAbsent || achievedAt != null) {
      map['achieved_at'] = Variable<DateTime>(achievedAt);
    }
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  UserMilestonesLocalCompanion toCompanion(bool nullToAbsent) {
    return UserMilestonesLocalCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      achieved: Value(achieved),
      achievedAt: achievedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(achievedAt),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
    );
  }

  factory UserMilestonesLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserMilestonesLocalData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      achieved: serializer.fromJson<bool>(json['achieved']),
      achievedAt: serializer.fromJson<DateTime?>(json['achievedAt']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'achieved': serializer.toJson<bool>(achieved),
      'achievedAt': serializer.toJson<DateTime?>(achievedAt),
      'value': serializer.toJson<String?>(value),
    };
  }

  UserMilestonesLocalData copyWith({
    String? id,
    String? title,
    String? description,
    bool? achieved,
    Value<DateTime?> achievedAt = const Value.absent(),
    Value<String?> value = const Value.absent(),
  }) => UserMilestonesLocalData(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    achieved: achieved ?? this.achieved,
    achievedAt: achievedAt.present ? achievedAt.value : this.achievedAt,
    value: value.present ? value.value : this.value,
  );
  UserMilestonesLocalData copyWithCompanion(UserMilestonesLocalCompanion data) {
    return UserMilestonesLocalData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      achieved: data.achieved.present ? data.achieved.value : this.achieved,
      achievedAt: data.achievedAt.present
          ? data.achievedAt.value
          : this.achievedAt,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserMilestonesLocalData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('achieved: $achieved, ')
          ..write('achievedAt: $achievedAt, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, description, achieved, achievedAt, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserMilestonesLocalData &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.achieved == this.achieved &&
          other.achievedAt == this.achievedAt &&
          other.value == this.value);
}

class UserMilestonesLocalCompanion
    extends UpdateCompanion<UserMilestonesLocalData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<bool> achieved;
  final Value<DateTime?> achievedAt;
  final Value<String?> value;
  final Value<int> rowid;
  const UserMilestonesLocalCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.achieved = const Value.absent(),
    this.achievedAt = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserMilestonesLocalCompanion.insert({
    required String id,
    required String title,
    required String description,
    this.achieved = const Value.absent(),
    this.achievedAt = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       description = Value(description);
  static Insertable<UserMilestonesLocalData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<bool>? achieved,
    Expression<DateTime>? achievedAt,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (achieved != null) 'achieved': achieved,
      if (achievedAt != null) 'achieved_at': achievedAt,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserMilestonesLocalCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? description,
    Value<bool>? achieved,
    Value<DateTime?>? achievedAt,
    Value<String?>? value,
    Value<int>? rowid,
  }) {
    return UserMilestonesLocalCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      achieved: achieved ?? this.achieved,
      achievedAt: achievedAt ?? this.achievedAt,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (achieved.present) {
      map['achieved'] = Variable<bool>(achieved.value);
    }
    if (achievedAt.present) {
      map['achieved_at'] = Variable<DateTime>(achievedAt.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserMilestonesLocalCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('achieved: $achieved, ')
          ..write('achievedAt: $achievedAt, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ResourcesLocalTable extends ResourcesLocal
    with TableInfo<$ResourcesLocalTable, ResourcesLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResourcesLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalUrlMeta = const VerificationMeta(
    'originalUrl',
  );
  @override
  late final GeneratedColumn<String> originalUrl = GeneratedColumn<String>(
    'original_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceNameMeta = const VerificationMeta(
    'sourceName',
  );
  @override
  late final GeneratedColumn<String> sourceName = GeneratedColumn<String>(
    'source_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resourceTypeMeta = const VerificationMeta(
    'resourceType',
  );
  @override
  late final GeneratedColumn<String> resourceType = GeneratedColumn<String>(
    'resource_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _skillMeta = const VerificationMeta('skill');
  @override
  late final GeneratedColumn<String> skill = GeneratedColumn<String>(
    'skill',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  @override
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
    'domain',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagsJsonMeta = const VerificationMeta(
    'tagsJson',
  );
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
    'tags_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transcriptAvailableMeta =
      const VerificationMeta('transcriptAvailable');
  @override
  late final GeneratedColumn<bool> transcriptAvailable = GeneratedColumn<bool>(
    'transcript_available',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("transcript_available" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _spanishSupportMeta = const VerificationMeta(
    'spanishSupport',
  );
  @override
  late final GeneratedColumn<bool> spanishSupport = GeneratedColumn<bool>(
    'spanish_support',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("spanish_support" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _estimatedMinutesMeta = const VerificationMeta(
    'estimatedMinutes',
  );
  @override
  late final GeneratedColumn<int> estimatedMinutes = GeneratedColumn<int>(
    'estimated_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(15),
  );
  static const VerificationMeta _recommendedForMeta = const VerificationMeta(
    'recommendedFor',
  );
  @override
  late final GeneratedColumn<String> recommendedFor = GeneratedColumn<String>(
    'recommended_for',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _spanishNotesMeta = const VerificationMeta(
    'spanishNotes',
  );
  @override
  late final GeneratedColumn<String> spanishNotes = GeneratedColumn<String>(
    'spanish_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<String> collectionId = GeneratedColumn<String>(
    'collection_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    originalUrl,
    sourceName,
    resourceType,
    skill,
    domain,
    level,
    tagsJson,
    transcriptAvailable,
    spanishSupport,
    estimatedMinutes,
    recommendedFor,
    spanishNotes,
    collectionId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'resources_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<ResourcesLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('original_url')) {
      context.handle(
        _originalUrlMeta,
        originalUrl.isAcceptableOrUnknown(
          data['original_url']!,
          _originalUrlMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalUrlMeta);
    }
    if (data.containsKey('source_name')) {
      context.handle(
        _sourceNameMeta,
        sourceName.isAcceptableOrUnknown(data['source_name']!, _sourceNameMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceNameMeta);
    }
    if (data.containsKey('resource_type')) {
      context.handle(
        _resourceTypeMeta,
        resourceType.isAcceptableOrUnknown(
          data['resource_type']!,
          _resourceTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_resourceTypeMeta);
    }
    if (data.containsKey('skill')) {
      context.handle(
        _skillMeta,
        skill.isAcceptableOrUnknown(data['skill']!, _skillMeta),
      );
    } else if (isInserting) {
      context.missing(_skillMeta);
    }
    if (data.containsKey('domain')) {
      context.handle(
        _domainMeta,
        domain.isAcceptableOrUnknown(data['domain']!, _domainMeta),
      );
    } else if (isInserting) {
      context.missing(_domainMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('tags_json')) {
      context.handle(
        _tagsJsonMeta,
        tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_tagsJsonMeta);
    }
    if (data.containsKey('transcript_available')) {
      context.handle(
        _transcriptAvailableMeta,
        transcriptAvailable.isAcceptableOrUnknown(
          data['transcript_available']!,
          _transcriptAvailableMeta,
        ),
      );
    }
    if (data.containsKey('spanish_support')) {
      context.handle(
        _spanishSupportMeta,
        spanishSupport.isAcceptableOrUnknown(
          data['spanish_support']!,
          _spanishSupportMeta,
        ),
      );
    }
    if (data.containsKey('estimated_minutes')) {
      context.handle(
        _estimatedMinutesMeta,
        estimatedMinutes.isAcceptableOrUnknown(
          data['estimated_minutes']!,
          _estimatedMinutesMeta,
        ),
      );
    }
    if (data.containsKey('recommended_for')) {
      context.handle(
        _recommendedForMeta,
        recommendedFor.isAcceptableOrUnknown(
          data['recommended_for']!,
          _recommendedForMeta,
        ),
      );
    }
    if (data.containsKey('spanish_notes')) {
      context.handle(
        _spanishNotesMeta,
        spanishNotes.isAcceptableOrUnknown(
          data['spanish_notes']!,
          _spanishNotesMeta,
        ),
      );
    }
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ResourcesLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResourcesLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      originalUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_url'],
      )!,
      sourceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_name'],
      )!,
      resourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource_type'],
      )!,
      skill: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}skill'],
      )!,
      domain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      tagsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags_json'],
      )!,
      transcriptAvailable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}transcript_available'],
      )!,
      spanishSupport: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}spanish_support'],
      )!,
      estimatedMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_minutes'],
      )!,
      recommendedFor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recommended_for'],
      ),
      spanishNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}spanish_notes'],
      ),
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_id'],
      ),
    );
  }

  @override
  $ResourcesLocalTable createAlias(String alias) {
    return $ResourcesLocalTable(attachedDatabase, alias);
  }
}

class ResourcesLocalData extends DataClass
    implements Insertable<ResourcesLocalData> {
  final String id;
  final String title;
  final String originalUrl;
  final String sourceName;
  final String resourceType;
  final String skill;
  final String domain;
  final String level;
  final String tagsJson;
  final bool transcriptAvailable;
  final bool spanishSupport;
  final int estimatedMinutes;
  final String? recommendedFor;
  final String? spanishNotes;
  final String? collectionId;
  const ResourcesLocalData({
    required this.id,
    required this.title,
    required this.originalUrl,
    required this.sourceName,
    required this.resourceType,
    required this.skill,
    required this.domain,
    required this.level,
    required this.tagsJson,
    required this.transcriptAvailable,
    required this.spanishSupport,
    required this.estimatedMinutes,
    this.recommendedFor,
    this.spanishNotes,
    this.collectionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['original_url'] = Variable<String>(originalUrl);
    map['source_name'] = Variable<String>(sourceName);
    map['resource_type'] = Variable<String>(resourceType);
    map['skill'] = Variable<String>(skill);
    map['domain'] = Variable<String>(domain);
    map['level'] = Variable<String>(level);
    map['tags_json'] = Variable<String>(tagsJson);
    map['transcript_available'] = Variable<bool>(transcriptAvailable);
    map['spanish_support'] = Variable<bool>(spanishSupport);
    map['estimated_minutes'] = Variable<int>(estimatedMinutes);
    if (!nullToAbsent || recommendedFor != null) {
      map['recommended_for'] = Variable<String>(recommendedFor);
    }
    if (!nullToAbsent || spanishNotes != null) {
      map['spanish_notes'] = Variable<String>(spanishNotes);
    }
    if (!nullToAbsent || collectionId != null) {
      map['collection_id'] = Variable<String>(collectionId);
    }
    return map;
  }

  ResourcesLocalCompanion toCompanion(bool nullToAbsent) {
    return ResourcesLocalCompanion(
      id: Value(id),
      title: Value(title),
      originalUrl: Value(originalUrl),
      sourceName: Value(sourceName),
      resourceType: Value(resourceType),
      skill: Value(skill),
      domain: Value(domain),
      level: Value(level),
      tagsJson: Value(tagsJson),
      transcriptAvailable: Value(transcriptAvailable),
      spanishSupport: Value(spanishSupport),
      estimatedMinutes: Value(estimatedMinutes),
      recommendedFor: recommendedFor == null && nullToAbsent
          ? const Value.absent()
          : Value(recommendedFor),
      spanishNotes: spanishNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(spanishNotes),
      collectionId: collectionId == null && nullToAbsent
          ? const Value.absent()
          : Value(collectionId),
    );
  }

  factory ResourcesLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResourcesLocalData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      originalUrl: serializer.fromJson<String>(json['originalUrl']),
      sourceName: serializer.fromJson<String>(json['sourceName']),
      resourceType: serializer.fromJson<String>(json['resourceType']),
      skill: serializer.fromJson<String>(json['skill']),
      domain: serializer.fromJson<String>(json['domain']),
      level: serializer.fromJson<String>(json['level']),
      tagsJson: serializer.fromJson<String>(json['tagsJson']),
      transcriptAvailable: serializer.fromJson<bool>(
        json['transcriptAvailable'],
      ),
      spanishSupport: serializer.fromJson<bool>(json['spanishSupport']),
      estimatedMinutes: serializer.fromJson<int>(json['estimatedMinutes']),
      recommendedFor: serializer.fromJson<String?>(json['recommendedFor']),
      spanishNotes: serializer.fromJson<String?>(json['spanishNotes']),
      collectionId: serializer.fromJson<String?>(json['collectionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'originalUrl': serializer.toJson<String>(originalUrl),
      'sourceName': serializer.toJson<String>(sourceName),
      'resourceType': serializer.toJson<String>(resourceType),
      'skill': serializer.toJson<String>(skill),
      'domain': serializer.toJson<String>(domain),
      'level': serializer.toJson<String>(level),
      'tagsJson': serializer.toJson<String>(tagsJson),
      'transcriptAvailable': serializer.toJson<bool>(transcriptAvailable),
      'spanishSupport': serializer.toJson<bool>(spanishSupport),
      'estimatedMinutes': serializer.toJson<int>(estimatedMinutes),
      'recommendedFor': serializer.toJson<String?>(recommendedFor),
      'spanishNotes': serializer.toJson<String?>(spanishNotes),
      'collectionId': serializer.toJson<String?>(collectionId),
    };
  }

  ResourcesLocalData copyWith({
    String? id,
    String? title,
    String? originalUrl,
    String? sourceName,
    String? resourceType,
    String? skill,
    String? domain,
    String? level,
    String? tagsJson,
    bool? transcriptAvailable,
    bool? spanishSupport,
    int? estimatedMinutes,
    Value<String?> recommendedFor = const Value.absent(),
    Value<String?> spanishNotes = const Value.absent(),
    Value<String?> collectionId = const Value.absent(),
  }) => ResourcesLocalData(
    id: id ?? this.id,
    title: title ?? this.title,
    originalUrl: originalUrl ?? this.originalUrl,
    sourceName: sourceName ?? this.sourceName,
    resourceType: resourceType ?? this.resourceType,
    skill: skill ?? this.skill,
    domain: domain ?? this.domain,
    level: level ?? this.level,
    tagsJson: tagsJson ?? this.tagsJson,
    transcriptAvailable: transcriptAvailable ?? this.transcriptAvailable,
    spanishSupport: spanishSupport ?? this.spanishSupport,
    estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
    recommendedFor: recommendedFor.present
        ? recommendedFor.value
        : this.recommendedFor,
    spanishNotes: spanishNotes.present ? spanishNotes.value : this.spanishNotes,
    collectionId: collectionId.present ? collectionId.value : this.collectionId,
  );
  ResourcesLocalData copyWithCompanion(ResourcesLocalCompanion data) {
    return ResourcesLocalData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      originalUrl: data.originalUrl.present
          ? data.originalUrl.value
          : this.originalUrl,
      sourceName: data.sourceName.present
          ? data.sourceName.value
          : this.sourceName,
      resourceType: data.resourceType.present
          ? data.resourceType.value
          : this.resourceType,
      skill: data.skill.present ? data.skill.value : this.skill,
      domain: data.domain.present ? data.domain.value : this.domain,
      level: data.level.present ? data.level.value : this.level,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      transcriptAvailable: data.transcriptAvailable.present
          ? data.transcriptAvailable.value
          : this.transcriptAvailable,
      spanishSupport: data.spanishSupport.present
          ? data.spanishSupport.value
          : this.spanishSupport,
      estimatedMinutes: data.estimatedMinutes.present
          ? data.estimatedMinutes.value
          : this.estimatedMinutes,
      recommendedFor: data.recommendedFor.present
          ? data.recommendedFor.value
          : this.recommendedFor,
      spanishNotes: data.spanishNotes.present
          ? data.spanishNotes.value
          : this.spanishNotes,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResourcesLocalData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('originalUrl: $originalUrl, ')
          ..write('sourceName: $sourceName, ')
          ..write('resourceType: $resourceType, ')
          ..write('skill: $skill, ')
          ..write('domain: $domain, ')
          ..write('level: $level, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('transcriptAvailable: $transcriptAvailable, ')
          ..write('spanishSupport: $spanishSupport, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('recommendedFor: $recommendedFor, ')
          ..write('spanishNotes: $spanishNotes, ')
          ..write('collectionId: $collectionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    originalUrl,
    sourceName,
    resourceType,
    skill,
    domain,
    level,
    tagsJson,
    transcriptAvailable,
    spanishSupport,
    estimatedMinutes,
    recommendedFor,
    spanishNotes,
    collectionId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResourcesLocalData &&
          other.id == this.id &&
          other.title == this.title &&
          other.originalUrl == this.originalUrl &&
          other.sourceName == this.sourceName &&
          other.resourceType == this.resourceType &&
          other.skill == this.skill &&
          other.domain == this.domain &&
          other.level == this.level &&
          other.tagsJson == this.tagsJson &&
          other.transcriptAvailable == this.transcriptAvailable &&
          other.spanishSupport == this.spanishSupport &&
          other.estimatedMinutes == this.estimatedMinutes &&
          other.recommendedFor == this.recommendedFor &&
          other.spanishNotes == this.spanishNotes &&
          other.collectionId == this.collectionId);
}

class ResourcesLocalCompanion extends UpdateCompanion<ResourcesLocalData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> originalUrl;
  final Value<String> sourceName;
  final Value<String> resourceType;
  final Value<String> skill;
  final Value<String> domain;
  final Value<String> level;
  final Value<String> tagsJson;
  final Value<bool> transcriptAvailable;
  final Value<bool> spanishSupport;
  final Value<int> estimatedMinutes;
  final Value<String?> recommendedFor;
  final Value<String?> spanishNotes;
  final Value<String?> collectionId;
  final Value<int> rowid;
  const ResourcesLocalCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.originalUrl = const Value.absent(),
    this.sourceName = const Value.absent(),
    this.resourceType = const Value.absent(),
    this.skill = const Value.absent(),
    this.domain = const Value.absent(),
    this.level = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.transcriptAvailable = const Value.absent(),
    this.spanishSupport = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.recommendedFor = const Value.absent(),
    this.spanishNotes = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ResourcesLocalCompanion.insert({
    required String id,
    required String title,
    required String originalUrl,
    required String sourceName,
    required String resourceType,
    required String skill,
    required String domain,
    required String level,
    required String tagsJson,
    this.transcriptAvailable = const Value.absent(),
    this.spanishSupport = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.recommendedFor = const Value.absent(),
    this.spanishNotes = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       originalUrl = Value(originalUrl),
       sourceName = Value(sourceName),
       resourceType = Value(resourceType),
       skill = Value(skill),
       domain = Value(domain),
       level = Value(level),
       tagsJson = Value(tagsJson);
  static Insertable<ResourcesLocalData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? originalUrl,
    Expression<String>? sourceName,
    Expression<String>? resourceType,
    Expression<String>? skill,
    Expression<String>? domain,
    Expression<String>? level,
    Expression<String>? tagsJson,
    Expression<bool>? transcriptAvailable,
    Expression<bool>? spanishSupport,
    Expression<int>? estimatedMinutes,
    Expression<String>? recommendedFor,
    Expression<String>? spanishNotes,
    Expression<String>? collectionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (originalUrl != null) 'original_url': originalUrl,
      if (sourceName != null) 'source_name': sourceName,
      if (resourceType != null) 'resource_type': resourceType,
      if (skill != null) 'skill': skill,
      if (domain != null) 'domain': domain,
      if (level != null) 'level': level,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (transcriptAvailable != null)
        'transcript_available': transcriptAvailable,
      if (spanishSupport != null) 'spanish_support': spanishSupport,
      if (estimatedMinutes != null) 'estimated_minutes': estimatedMinutes,
      if (recommendedFor != null) 'recommended_for': recommendedFor,
      if (spanishNotes != null) 'spanish_notes': spanishNotes,
      if (collectionId != null) 'collection_id': collectionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ResourcesLocalCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? originalUrl,
    Value<String>? sourceName,
    Value<String>? resourceType,
    Value<String>? skill,
    Value<String>? domain,
    Value<String>? level,
    Value<String>? tagsJson,
    Value<bool>? transcriptAvailable,
    Value<bool>? spanishSupport,
    Value<int>? estimatedMinutes,
    Value<String?>? recommendedFor,
    Value<String?>? spanishNotes,
    Value<String?>? collectionId,
    Value<int>? rowid,
  }) {
    return ResourcesLocalCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      originalUrl: originalUrl ?? this.originalUrl,
      sourceName: sourceName ?? this.sourceName,
      resourceType: resourceType ?? this.resourceType,
      skill: skill ?? this.skill,
      domain: domain ?? this.domain,
      level: level ?? this.level,
      tagsJson: tagsJson ?? this.tagsJson,
      transcriptAvailable: transcriptAvailable ?? this.transcriptAvailable,
      spanishSupport: spanishSupport ?? this.spanishSupport,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      recommendedFor: recommendedFor ?? this.recommendedFor,
      spanishNotes: spanishNotes ?? this.spanishNotes,
      collectionId: collectionId ?? this.collectionId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (originalUrl.present) {
      map['original_url'] = Variable<String>(originalUrl.value);
    }
    if (sourceName.present) {
      map['source_name'] = Variable<String>(sourceName.value);
    }
    if (resourceType.present) {
      map['resource_type'] = Variable<String>(resourceType.value);
    }
    if (skill.present) {
      map['skill'] = Variable<String>(skill.value);
    }
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    if (transcriptAvailable.present) {
      map['transcript_available'] = Variable<bool>(transcriptAvailable.value);
    }
    if (spanishSupport.present) {
      map['spanish_support'] = Variable<bool>(spanishSupport.value);
    }
    if (estimatedMinutes.present) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes.value);
    }
    if (recommendedFor.present) {
      map['recommended_for'] = Variable<String>(recommendedFor.value);
    }
    if (spanishNotes.present) {
      map['spanish_notes'] = Variable<String>(spanishNotes.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResourcesLocalCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('originalUrl: $originalUrl, ')
          ..write('sourceName: $sourceName, ')
          ..write('resourceType: $resourceType, ')
          ..write('skill: $skill, ')
          ..write('domain: $domain, ')
          ..write('level: $level, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('transcriptAvailable: $transcriptAvailable, ')
          ..write('spanishSupport: $spanishSupport, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('recommendedFor: $recommendedFor, ')
          ..write('spanishNotes: $spanishNotes, ')
          ..write('collectionId: $collectionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ResourceCollectionsLocalTable extends ResourceCollectionsLocal
    with
        TableInfo<
          $ResourceCollectionsLocalTable,
          ResourceCollectionsLocalData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResourceCollectionsLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('bookmark'),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#0D9488'),
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    icon,
    color,
    orderIndex,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'resource_collections_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<ResourceCollectionsLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ResourceCollectionsLocalData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResourceCollectionsLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
    );
  }

  @override
  $ResourceCollectionsLocalTable createAlias(String alias) {
    return $ResourceCollectionsLocalTable(attachedDatabase, alias);
  }
}

class ResourceCollectionsLocalData extends DataClass
    implements Insertable<ResourceCollectionsLocalData> {
  final String id;
  final String name;
  final String? description;
  final String icon;
  final String color;
  final int orderIndex;
  const ResourceCollectionsLocalData({
    required this.id,
    required this.name,
    this.description,
    required this.icon,
    required this.color,
    required this.orderIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['icon'] = Variable<String>(icon);
    map['color'] = Variable<String>(color);
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  ResourceCollectionsLocalCompanion toCompanion(bool nullToAbsent) {
    return ResourceCollectionsLocalCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      icon: Value(icon),
      color: Value(color),
      orderIndex: Value(orderIndex),
    );
  }

  factory ResourceCollectionsLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResourceCollectionsLocalData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<String>(json['color']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<String>(color),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }

  ResourceCollectionsLocalData copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    String? icon,
    String? color,
    int? orderIndex,
  }) => ResourceCollectionsLocalData(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    orderIndex: orderIndex ?? this.orderIndex,
  );
  ResourceCollectionsLocalData copyWithCompanion(
    ResourceCollectionsLocalCompanion data,
  ) {
    return ResourceCollectionsLocalData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResourceCollectionsLocalData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, description, icon, color, orderIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResourceCollectionsLocalData &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.orderIndex == this.orderIndex);
}

class ResourceCollectionsLocalCompanion
    extends UpdateCompanion<ResourceCollectionsLocalData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> icon;
  final Value<String> color;
  final Value<int> orderIndex;
  final Value<int> rowid;
  const ResourceCollectionsLocalCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ResourceCollectionsLocalCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<ResourceCollectionsLocalData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? icon,
    Expression<String>? color,
    Expression<int>? orderIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (orderIndex != null) 'order_index': orderIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ResourceCollectionsLocalCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<String>? icon,
    Value<String>? color,
    Value<int>? orderIndex,
    Value<int>? rowid,
  }) {
    return ResourceCollectionsLocalCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      orderIndex: orderIndex ?? this.orderIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResourceCollectionsLocalCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UnitResourceLinksLocalTable extends UnitResourceLinksLocal
    with TableInfo<$UnitResourceLinksLocalTable, UnitResourceLinksLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnitResourceLinksLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _resourceIdMeta = const VerificationMeta(
    'resourceId',
  );
  @override
  late final GeneratedColumn<String> resourceId = GeneratedColumn<String>(
    'resource_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetTypeMeta = const VerificationMeta(
    'targetType',
  );
  @override
  late final GeneratedColumn<String> targetType = GeneratedColumn<String>(
    'target_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetIdMeta = const VerificationMeta(
    'targetId',
  );
  @override
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
    'target_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relevanceNoteMeta = const VerificationMeta(
    'relevanceNote',
  );
  @override
  late final GeneratedColumn<String> relevanceNote = GeneratedColumn<String>(
    'relevance_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    resourceId,
    targetType,
    targetId,
    relevanceNote,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'unit_resource_links_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<UnitResourceLinksLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('resource_id')) {
      context.handle(
        _resourceIdMeta,
        resourceId.isAcceptableOrUnknown(data['resource_id']!, _resourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_resourceIdMeta);
    }
    if (data.containsKey('target_type')) {
      context.handle(
        _targetTypeMeta,
        targetType.isAcceptableOrUnknown(data['target_type']!, _targetTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_targetTypeMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(
        _targetIdMeta,
        targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_targetIdMeta);
    }
    if (data.containsKey('relevance_note')) {
      context.handle(
        _relevanceNoteMeta,
        relevanceNote.isAcceptableOrUnknown(
          data['relevance_note']!,
          _relevanceNoteMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UnitResourceLinksLocalData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UnitResourceLinksLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      resourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource_id'],
      )!,
      targetType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_type'],
      )!,
      targetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_id'],
      )!,
      relevanceNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relevance_note'],
      ),
    );
  }

  @override
  $UnitResourceLinksLocalTable createAlias(String alias) {
    return $UnitResourceLinksLocalTable(attachedDatabase, alias);
  }
}

class UnitResourceLinksLocalData extends DataClass
    implements Insertable<UnitResourceLinksLocalData> {
  final int id;
  final String resourceId;
  final String targetType;
  final String targetId;
  final String? relevanceNote;
  const UnitResourceLinksLocalData({
    required this.id,
    required this.resourceId,
    required this.targetType,
    required this.targetId,
    this.relevanceNote,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['resource_id'] = Variable<String>(resourceId);
    map['target_type'] = Variable<String>(targetType);
    map['target_id'] = Variable<String>(targetId);
    if (!nullToAbsent || relevanceNote != null) {
      map['relevance_note'] = Variable<String>(relevanceNote);
    }
    return map;
  }

  UnitResourceLinksLocalCompanion toCompanion(bool nullToAbsent) {
    return UnitResourceLinksLocalCompanion(
      id: Value(id),
      resourceId: Value(resourceId),
      targetType: Value(targetType),
      targetId: Value(targetId),
      relevanceNote: relevanceNote == null && nullToAbsent
          ? const Value.absent()
          : Value(relevanceNote),
    );
  }

  factory UnitResourceLinksLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UnitResourceLinksLocalData(
      id: serializer.fromJson<int>(json['id']),
      resourceId: serializer.fromJson<String>(json['resourceId']),
      targetType: serializer.fromJson<String>(json['targetType']),
      targetId: serializer.fromJson<String>(json['targetId']),
      relevanceNote: serializer.fromJson<String?>(json['relevanceNote']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'resourceId': serializer.toJson<String>(resourceId),
      'targetType': serializer.toJson<String>(targetType),
      'targetId': serializer.toJson<String>(targetId),
      'relevanceNote': serializer.toJson<String?>(relevanceNote),
    };
  }

  UnitResourceLinksLocalData copyWith({
    int? id,
    String? resourceId,
    String? targetType,
    String? targetId,
    Value<String?> relevanceNote = const Value.absent(),
  }) => UnitResourceLinksLocalData(
    id: id ?? this.id,
    resourceId: resourceId ?? this.resourceId,
    targetType: targetType ?? this.targetType,
    targetId: targetId ?? this.targetId,
    relevanceNote: relevanceNote.present
        ? relevanceNote.value
        : this.relevanceNote,
  );
  UnitResourceLinksLocalData copyWithCompanion(
    UnitResourceLinksLocalCompanion data,
  ) {
    return UnitResourceLinksLocalData(
      id: data.id.present ? data.id.value : this.id,
      resourceId: data.resourceId.present
          ? data.resourceId.value
          : this.resourceId,
      targetType: data.targetType.present
          ? data.targetType.value
          : this.targetType,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      relevanceNote: data.relevanceNote.present
          ? data.relevanceNote.value
          : this.relevanceNote,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UnitResourceLinksLocalData(')
          ..write('id: $id, ')
          ..write('resourceId: $resourceId, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId, ')
          ..write('relevanceNote: $relevanceNote')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, resourceId, targetType, targetId, relevanceNote);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UnitResourceLinksLocalData &&
          other.id == this.id &&
          other.resourceId == this.resourceId &&
          other.targetType == this.targetType &&
          other.targetId == this.targetId &&
          other.relevanceNote == this.relevanceNote);
}

class UnitResourceLinksLocalCompanion
    extends UpdateCompanion<UnitResourceLinksLocalData> {
  final Value<int> id;
  final Value<String> resourceId;
  final Value<String> targetType;
  final Value<String> targetId;
  final Value<String?> relevanceNote;
  const UnitResourceLinksLocalCompanion({
    this.id = const Value.absent(),
    this.resourceId = const Value.absent(),
    this.targetType = const Value.absent(),
    this.targetId = const Value.absent(),
    this.relevanceNote = const Value.absent(),
  });
  UnitResourceLinksLocalCompanion.insert({
    this.id = const Value.absent(),
    required String resourceId,
    required String targetType,
    required String targetId,
    this.relevanceNote = const Value.absent(),
  }) : resourceId = Value(resourceId),
       targetType = Value(targetType),
       targetId = Value(targetId);
  static Insertable<UnitResourceLinksLocalData> custom({
    Expression<int>? id,
    Expression<String>? resourceId,
    Expression<String>? targetType,
    Expression<String>? targetId,
    Expression<String>? relevanceNote,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (resourceId != null) 'resource_id': resourceId,
      if (targetType != null) 'target_type': targetType,
      if (targetId != null) 'target_id': targetId,
      if (relevanceNote != null) 'relevance_note': relevanceNote,
    });
  }

  UnitResourceLinksLocalCompanion copyWith({
    Value<int>? id,
    Value<String>? resourceId,
    Value<String>? targetType,
    Value<String>? targetId,
    Value<String?>? relevanceNote,
  }) {
    return UnitResourceLinksLocalCompanion(
      id: id ?? this.id,
      resourceId: resourceId ?? this.resourceId,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      relevanceNote: relevanceNote ?? this.relevanceNote,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (resourceId.present) {
      map['resource_id'] = Variable<String>(resourceId.value);
    }
    if (targetType.present) {
      map['target_type'] = Variable<String>(targetType.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (relevanceNote.present) {
      map['relevance_note'] = Variable<String>(relevanceNote.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UnitResourceLinksLocalCompanion(')
          ..write('id: $id, ')
          ..write('resourceId: $resourceId, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId, ')
          ..write('relevanceNote: $relevanceNote')
          ..write(')'))
        .toString();
  }
}

class $ResourceUsageLogsLocalTable extends ResourceUsageLogsLocal
    with TableInfo<$ResourceUsageLogsLocalTable, ResourceUsageLogsLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResourceUsageLogsLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _resourceIdMeta = const VerificationMeta(
    'resourceId',
  );
  @override
  late final GeneratedColumn<String> resourceId = GeneratedColumn<String>(
    'resource_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitIdMeta = const VerificationMeta('unitId');
  @override
  late final GeneratedColumn<String> unitId = GeneratedColumn<String>(
    'unit_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('open'),
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    resourceId,
    unitId,
    eventType,
    durationSeconds,
    createdAt,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'resource_usage_logs_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<ResourceUsageLogsLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('resource_id')) {
      context.handle(
        _resourceIdMeta,
        resourceId.isAcceptableOrUnknown(data['resource_id']!, _resourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_resourceIdMeta);
    }
    if (data.containsKey('unit_id')) {
      context.handle(
        _unitIdMeta,
        unitId.isAcceptableOrUnknown(data['unit_id']!, _unitIdMeta),
      );
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ResourceUsageLogsLocalData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResourceUsageLogsLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      resourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource_id'],
      )!,
      unitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_id'],
      ),
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $ResourceUsageLogsLocalTable createAlias(String alias) {
    return $ResourceUsageLogsLocalTable(attachedDatabase, alias);
  }
}

class ResourceUsageLogsLocalData extends DataClass
    implements Insertable<ResourceUsageLogsLocalData> {
  final int id;
  final String resourceId;
  final String? unitId;
  final String eventType;
  final int durationSeconds;
  final DateTime createdAt;
  final bool isSynced;
  const ResourceUsageLogsLocalData({
    required this.id,
    required this.resourceId,
    this.unitId,
    required this.eventType,
    required this.durationSeconds,
    required this.createdAt,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['resource_id'] = Variable<String>(resourceId);
    if (!nullToAbsent || unitId != null) {
      map['unit_id'] = Variable<String>(unitId);
    }
    map['event_type'] = Variable<String>(eventType);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  ResourceUsageLogsLocalCompanion toCompanion(bool nullToAbsent) {
    return ResourceUsageLogsLocalCompanion(
      id: Value(id),
      resourceId: Value(resourceId),
      unitId: unitId == null && nullToAbsent
          ? const Value.absent()
          : Value(unitId),
      eventType: Value(eventType),
      durationSeconds: Value(durationSeconds),
      createdAt: Value(createdAt),
      isSynced: Value(isSynced),
    );
  }

  factory ResourceUsageLogsLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResourceUsageLogsLocalData(
      id: serializer.fromJson<int>(json['id']),
      resourceId: serializer.fromJson<String>(json['resourceId']),
      unitId: serializer.fromJson<String?>(json['unitId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'resourceId': serializer.toJson<String>(resourceId),
      'unitId': serializer.toJson<String?>(unitId),
      'eventType': serializer.toJson<String>(eventType),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  ResourceUsageLogsLocalData copyWith({
    int? id,
    String? resourceId,
    Value<String?> unitId = const Value.absent(),
    String? eventType,
    int? durationSeconds,
    DateTime? createdAt,
    bool? isSynced,
  }) => ResourceUsageLogsLocalData(
    id: id ?? this.id,
    resourceId: resourceId ?? this.resourceId,
    unitId: unitId.present ? unitId.value : this.unitId,
    eventType: eventType ?? this.eventType,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    createdAt: createdAt ?? this.createdAt,
    isSynced: isSynced ?? this.isSynced,
  );
  ResourceUsageLogsLocalData copyWithCompanion(
    ResourceUsageLogsLocalCompanion data,
  ) {
    return ResourceUsageLogsLocalData(
      id: data.id.present ? data.id.value : this.id,
      resourceId: data.resourceId.present
          ? data.resourceId.value
          : this.resourceId,
      unitId: data.unitId.present ? data.unitId.value : this.unitId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResourceUsageLogsLocalData(')
          ..write('id: $id, ')
          ..write('resourceId: $resourceId, ')
          ..write('unitId: $unitId, ')
          ..write('eventType: $eventType, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    resourceId,
    unitId,
    eventType,
    durationSeconds,
    createdAt,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResourceUsageLogsLocalData &&
          other.id == this.id &&
          other.resourceId == this.resourceId &&
          other.unitId == this.unitId &&
          other.eventType == this.eventType &&
          other.durationSeconds == this.durationSeconds &&
          other.createdAt == this.createdAt &&
          other.isSynced == this.isSynced);
}

class ResourceUsageLogsLocalCompanion
    extends UpdateCompanion<ResourceUsageLogsLocalData> {
  final Value<int> id;
  final Value<String> resourceId;
  final Value<String?> unitId;
  final Value<String> eventType;
  final Value<int> durationSeconds;
  final Value<DateTime> createdAt;
  final Value<bool> isSynced;
  const ResourceUsageLogsLocalCompanion({
    this.id = const Value.absent(),
    this.resourceId = const Value.absent(),
    this.unitId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
  });
  ResourceUsageLogsLocalCompanion.insert({
    this.id = const Value.absent(),
    required String resourceId,
    this.unitId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    required DateTime createdAt,
    this.isSynced = const Value.absent(),
  }) : resourceId = Value(resourceId),
       createdAt = Value(createdAt);
  static Insertable<ResourceUsageLogsLocalData> custom({
    Expression<int>? id,
    Expression<String>? resourceId,
    Expression<String>? unitId,
    Expression<String>? eventType,
    Expression<int>? durationSeconds,
    Expression<DateTime>? createdAt,
    Expression<bool>? isSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (resourceId != null) 'resource_id': resourceId,
      if (unitId != null) 'unit_id': unitId,
      if (eventType != null) 'event_type': eventType,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (createdAt != null) 'created_at': createdAt,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  ResourceUsageLogsLocalCompanion copyWith({
    Value<int>? id,
    Value<String>? resourceId,
    Value<String?>? unitId,
    Value<String>? eventType,
    Value<int>? durationSeconds,
    Value<DateTime>? createdAt,
    Value<bool>? isSynced,
  }) {
    return ResourceUsageLogsLocalCompanion(
      id: id ?? this.id,
      resourceId: resourceId ?? this.resourceId,
      unitId: unitId ?? this.unitId,
      eventType: eventType ?? this.eventType,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (resourceId.present) {
      map['resource_id'] = Variable<String>(resourceId.value);
    }
    if (unitId.present) {
      map['unit_id'] = Variable<String>(unitId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResourceUsageLogsLocalCompanion(')
          ..write('id: $id, ')
          ..write('resourceId: $resourceId, ')
          ..write('unitId: $unitId, ')
          ..write('eventType: $eventType, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }
}

class $UserProfilesLocalTable extends UserProfilesLocal
    with TableInfo<$UserProfilesLocalTable, UserProfilesLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetLevelMeta = const VerificationMeta(
    'targetLevel',
  );
  @override
  late final GeneratedColumn<String> targetLevel = GeneratedColumn<String>(
    'target_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('B2'),
  );
  static const VerificationMeta _roleTitleMeta = const VerificationMeta(
    'roleTitle',
  );
  @override
  late final GeneratedColumn<String> roleTitle = GeneratedColumn<String>(
    'role_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Software Engineer'),
  );
  static const VerificationMeta _learningGoalMeta = const VerificationMeta(
    'learningGoal',
  );
  @override
  late final GeneratedColumn<String> learningGoal = GeneratedColumn<String>(
    'learning_goal',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('interview_prep'),
  );
  static const VerificationMeta _dailyGoalMinutesMeta = const VerificationMeta(
    'dailyGoalMinutes',
  );
  @override
  late final GeneratedColumn<int> dailyGoalMinutes = GeneratedColumn<int>(
    'daily_goal_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(20),
  );
  static const VerificationMeta _totalXpMeta = const VerificationMeta(
    'totalXp',
  );
  @override
  late final GeneratedColumn<int> totalXp = GeneratedColumn<int>(
    'total_xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _streakDaysMeta = const VerificationMeta(
    'streakDays',
  );
  @override
  late final GeneratedColumn<int> streakDays = GeneratedColumn<int>(
    'streak_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastActiveDateMeta = const VerificationMeta(
    'lastActiveDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastActiveDate =
      GeneratedColumn<DateTime>(
        'last_active_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCurrentMeta = const VerificationMeta(
    'isCurrent',
  );
  @override
  late final GeneratedColumn<bool> isCurrent = GeneratedColumn<bool>(
    'is_current',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_current" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    email,
    avatarUrl,
    targetLevel,
    roleTitle,
    learningGoal,
    dailyGoalMinutes,
    totalXp,
    streakDays,
    lastActiveDate,
    createdAt,
    isCurrent,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfilesLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('target_level')) {
      context.handle(
        _targetLevelMeta,
        targetLevel.isAcceptableOrUnknown(
          data['target_level']!,
          _targetLevelMeta,
        ),
      );
    }
    if (data.containsKey('role_title')) {
      context.handle(
        _roleTitleMeta,
        roleTitle.isAcceptableOrUnknown(data['role_title']!, _roleTitleMeta),
      );
    }
    if (data.containsKey('learning_goal')) {
      context.handle(
        _learningGoalMeta,
        learningGoal.isAcceptableOrUnknown(
          data['learning_goal']!,
          _learningGoalMeta,
        ),
      );
    }
    if (data.containsKey('daily_goal_minutes')) {
      context.handle(
        _dailyGoalMinutesMeta,
        dailyGoalMinutes.isAcceptableOrUnknown(
          data['daily_goal_minutes']!,
          _dailyGoalMinutesMeta,
        ),
      );
    }
    if (data.containsKey('total_xp')) {
      context.handle(
        _totalXpMeta,
        totalXp.isAcceptableOrUnknown(data['total_xp']!, _totalXpMeta),
      );
    }
    if (data.containsKey('streak_days')) {
      context.handle(
        _streakDaysMeta,
        streakDays.isAcceptableOrUnknown(data['streak_days']!, _streakDaysMeta),
      );
    }
    if (data.containsKey('last_active_date')) {
      context.handle(
        _lastActiveDateMeta,
        lastActiveDate.isAcceptableOrUnknown(
          data['last_active_date']!,
          _lastActiveDateMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_current')) {
      context.handle(
        _isCurrentMeta,
        isCurrent.isAcceptableOrUnknown(data['is_current']!, _isCurrentMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfilesLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfilesLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      targetLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_level'],
      )!,
      roleTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role_title'],
      )!,
      learningGoal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}learning_goal'],
      )!,
      dailyGoalMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_goal_minutes'],
      )!,
      totalXp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_xp'],
      )!,
      streakDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}streak_days'],
      )!,
      lastActiveDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_active_date'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isCurrent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_current'],
      )!,
    );
  }

  @override
  $UserProfilesLocalTable createAlias(String alias) {
    return $UserProfilesLocalTable(attachedDatabase, alias);
  }
}

class UserProfilesLocalData extends DataClass
    implements Insertable<UserProfilesLocalData> {
  final String id;
  final String displayName;
  final String? email;
  final String? avatarUrl;
  final String targetLevel;
  final String roleTitle;
  final String learningGoal;
  final int dailyGoalMinutes;
  final int totalXp;
  final int streakDays;
  final DateTime? lastActiveDate;
  final DateTime createdAt;
  final bool isCurrent;
  const UserProfilesLocalData({
    required this.id,
    required this.displayName,
    this.email,
    this.avatarUrl,
    required this.targetLevel,
    required this.roleTitle,
    required this.learningGoal,
    required this.dailyGoalMinutes,
    required this.totalXp,
    required this.streakDays,
    this.lastActiveDate,
    required this.createdAt,
    required this.isCurrent,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    map['target_level'] = Variable<String>(targetLevel);
    map['role_title'] = Variable<String>(roleTitle);
    map['learning_goal'] = Variable<String>(learningGoal);
    map['daily_goal_minutes'] = Variable<int>(dailyGoalMinutes);
    map['total_xp'] = Variable<int>(totalXp);
    map['streak_days'] = Variable<int>(streakDays);
    if (!nullToAbsent || lastActiveDate != null) {
      map['last_active_date'] = Variable<DateTime>(lastActiveDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_current'] = Variable<bool>(isCurrent);
    return map;
  }

  UserProfilesLocalCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesLocalCompanion(
      id: Value(id),
      displayName: Value(displayName),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      targetLevel: Value(targetLevel),
      roleTitle: Value(roleTitle),
      learningGoal: Value(learningGoal),
      dailyGoalMinutes: Value(dailyGoalMinutes),
      totalXp: Value(totalXp),
      streakDays: Value(streakDays),
      lastActiveDate: lastActiveDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastActiveDate),
      createdAt: Value(createdAt),
      isCurrent: Value(isCurrent),
    );
  }

  factory UserProfilesLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfilesLocalData(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      email: serializer.fromJson<String?>(json['email']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      targetLevel: serializer.fromJson<String>(json['targetLevel']),
      roleTitle: serializer.fromJson<String>(json['roleTitle']),
      learningGoal: serializer.fromJson<String>(json['learningGoal']),
      dailyGoalMinutes: serializer.fromJson<int>(json['dailyGoalMinutes']),
      totalXp: serializer.fromJson<int>(json['totalXp']),
      streakDays: serializer.fromJson<int>(json['streakDays']),
      lastActiveDate: serializer.fromJson<DateTime?>(json['lastActiveDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isCurrent: serializer.fromJson<bool>(json['isCurrent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String>(displayName),
      'email': serializer.toJson<String?>(email),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'targetLevel': serializer.toJson<String>(targetLevel),
      'roleTitle': serializer.toJson<String>(roleTitle),
      'learningGoal': serializer.toJson<String>(learningGoal),
      'dailyGoalMinutes': serializer.toJson<int>(dailyGoalMinutes),
      'totalXp': serializer.toJson<int>(totalXp),
      'streakDays': serializer.toJson<int>(streakDays),
      'lastActiveDate': serializer.toJson<DateTime?>(lastActiveDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isCurrent': serializer.toJson<bool>(isCurrent),
    };
  }

  UserProfilesLocalData copyWith({
    String? id,
    String? displayName,
    Value<String?> email = const Value.absent(),
    Value<String?> avatarUrl = const Value.absent(),
    String? targetLevel,
    String? roleTitle,
    String? learningGoal,
    int? dailyGoalMinutes,
    int? totalXp,
    int? streakDays,
    Value<DateTime?> lastActiveDate = const Value.absent(),
    DateTime? createdAt,
    bool? isCurrent,
  }) => UserProfilesLocalData(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    email: email.present ? email.value : this.email,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    targetLevel: targetLevel ?? this.targetLevel,
    roleTitle: roleTitle ?? this.roleTitle,
    learningGoal: learningGoal ?? this.learningGoal,
    dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
    totalXp: totalXp ?? this.totalXp,
    streakDays: streakDays ?? this.streakDays,
    lastActiveDate: lastActiveDate.present
        ? lastActiveDate.value
        : this.lastActiveDate,
    createdAt: createdAt ?? this.createdAt,
    isCurrent: isCurrent ?? this.isCurrent,
  );
  UserProfilesLocalData copyWithCompanion(UserProfilesLocalCompanion data) {
    return UserProfilesLocalData(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      email: data.email.present ? data.email.value : this.email,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      targetLevel: data.targetLevel.present
          ? data.targetLevel.value
          : this.targetLevel,
      roleTitle: data.roleTitle.present ? data.roleTitle.value : this.roleTitle,
      learningGoal: data.learningGoal.present
          ? data.learningGoal.value
          : this.learningGoal,
      dailyGoalMinutes: data.dailyGoalMinutes.present
          ? data.dailyGoalMinutes.value
          : this.dailyGoalMinutes,
      totalXp: data.totalXp.present ? data.totalXp.value : this.totalXp,
      streakDays: data.streakDays.present
          ? data.streakDays.value
          : this.streakDays,
      lastActiveDate: data.lastActiveDate.present
          ? data.lastActiveDate.value
          : this.lastActiveDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isCurrent: data.isCurrent.present ? data.isCurrent.value : this.isCurrent,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesLocalData(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('email: $email, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('targetLevel: $targetLevel, ')
          ..write('roleTitle: $roleTitle, ')
          ..write('learningGoal: $learningGoal, ')
          ..write('dailyGoalMinutes: $dailyGoalMinutes, ')
          ..write('totalXp: $totalXp, ')
          ..write('streakDays: $streakDays, ')
          ..write('lastActiveDate: $lastActiveDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('isCurrent: $isCurrent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    email,
    avatarUrl,
    targetLevel,
    roleTitle,
    learningGoal,
    dailyGoalMinutes,
    totalXp,
    streakDays,
    lastActiveDate,
    createdAt,
    isCurrent,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfilesLocalData &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.email == this.email &&
          other.avatarUrl == this.avatarUrl &&
          other.targetLevel == this.targetLevel &&
          other.roleTitle == this.roleTitle &&
          other.learningGoal == this.learningGoal &&
          other.dailyGoalMinutes == this.dailyGoalMinutes &&
          other.totalXp == this.totalXp &&
          other.streakDays == this.streakDays &&
          other.lastActiveDate == this.lastActiveDate &&
          other.createdAt == this.createdAt &&
          other.isCurrent == this.isCurrent);
}

class UserProfilesLocalCompanion
    extends UpdateCompanion<UserProfilesLocalData> {
  final Value<String> id;
  final Value<String> displayName;
  final Value<String?> email;
  final Value<String?> avatarUrl;
  final Value<String> targetLevel;
  final Value<String> roleTitle;
  final Value<String> learningGoal;
  final Value<int> dailyGoalMinutes;
  final Value<int> totalXp;
  final Value<int> streakDays;
  final Value<DateTime?> lastActiveDate;
  final Value<DateTime> createdAt;
  final Value<bool> isCurrent;
  final Value<int> rowid;
  const UserProfilesLocalCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.email = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.targetLevel = const Value.absent(),
    this.roleTitle = const Value.absent(),
    this.learningGoal = const Value.absent(),
    this.dailyGoalMinutes = const Value.absent(),
    this.totalXp = const Value.absent(),
    this.streakDays = const Value.absent(),
    this.lastActiveDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isCurrent = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProfilesLocalCompanion.insert({
    required String id,
    required String displayName,
    this.email = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.targetLevel = const Value.absent(),
    this.roleTitle = const Value.absent(),
    this.learningGoal = const Value.absent(),
    this.dailyGoalMinutes = const Value.absent(),
    this.totalXp = const Value.absent(),
    this.streakDays = const Value.absent(),
    this.lastActiveDate = const Value.absent(),
    required DateTime createdAt,
    this.isCurrent = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       displayName = Value(displayName),
       createdAt = Value(createdAt);
  static Insertable<UserProfilesLocalData> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<String>? email,
    Expression<String>? avatarUrl,
    Expression<String>? targetLevel,
    Expression<String>? roleTitle,
    Expression<String>? learningGoal,
    Expression<int>? dailyGoalMinutes,
    Expression<int>? totalXp,
    Expression<int>? streakDays,
    Expression<DateTime>? lastActiveDate,
    Expression<DateTime>? createdAt,
    Expression<bool>? isCurrent,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (email != null) 'email': email,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (targetLevel != null) 'target_level': targetLevel,
      if (roleTitle != null) 'role_title': roleTitle,
      if (learningGoal != null) 'learning_goal': learningGoal,
      if (dailyGoalMinutes != null) 'daily_goal_minutes': dailyGoalMinutes,
      if (totalXp != null) 'total_xp': totalXp,
      if (streakDays != null) 'streak_days': streakDays,
      if (lastActiveDate != null) 'last_active_date': lastActiveDate,
      if (createdAt != null) 'created_at': createdAt,
      if (isCurrent != null) 'is_current': isCurrent,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProfilesLocalCompanion copyWith({
    Value<String>? id,
    Value<String>? displayName,
    Value<String?>? email,
    Value<String?>? avatarUrl,
    Value<String>? targetLevel,
    Value<String>? roleTitle,
    Value<String>? learningGoal,
    Value<int>? dailyGoalMinutes,
    Value<int>? totalXp,
    Value<int>? streakDays,
    Value<DateTime?>? lastActiveDate,
    Value<DateTime>? createdAt,
    Value<bool>? isCurrent,
    Value<int>? rowid,
  }) {
    return UserProfilesLocalCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      targetLevel: targetLevel ?? this.targetLevel,
      roleTitle: roleTitle ?? this.roleTitle,
      learningGoal: learningGoal ?? this.learningGoal,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      totalXp: totalXp ?? this.totalXp,
      streakDays: streakDays ?? this.streakDays,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      createdAt: createdAt ?? this.createdAt,
      isCurrent: isCurrent ?? this.isCurrent,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (targetLevel.present) {
      map['target_level'] = Variable<String>(targetLevel.value);
    }
    if (roleTitle.present) {
      map['role_title'] = Variable<String>(roleTitle.value);
    }
    if (learningGoal.present) {
      map['learning_goal'] = Variable<String>(learningGoal.value);
    }
    if (dailyGoalMinutes.present) {
      map['daily_goal_minutes'] = Variable<int>(dailyGoalMinutes.value);
    }
    if (totalXp.present) {
      map['total_xp'] = Variable<int>(totalXp.value);
    }
    if (streakDays.present) {
      map['streak_days'] = Variable<int>(streakDays.value);
    }
    if (lastActiveDate.present) {
      map['last_active_date'] = Variable<DateTime>(lastActiveDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isCurrent.present) {
      map['is_current'] = Variable<bool>(isCurrent.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesLocalCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('email: $email, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('targetLevel: $targetLevel, ')
          ..write('roleTitle: $roleTitle, ')
          ..write('learningGoal: $learningGoal, ')
          ..write('dailyGoalMinutes: $dailyGoalMinutes, ')
          ..write('totalXp: $totalXp, ')
          ..write('streakDays: $streakDays, ')
          ..write('lastActiveDate: $lastActiveDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('isCurrent: $isCurrent, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserAchievementsLocalTable extends UserAchievementsLocal
    with TableInfo<$UserAchievementsLocalTable, UserAchievementsLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserAchievementsLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _badgeKeyMeta = const VerificationMeta(
    'badgeKey',
  );
  @override
  late final GeneratedColumn<String> badgeKey = GeneratedColumn<String>(
    'badge_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconNameMeta = const VerificationMeta(
    'iconName',
  );
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
    'icon_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('star'),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('general'),
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _progressMeta = const VerificationMeta(
    'progress',
  );
  @override
  late final GeneratedColumn<double> progress = GeneratedColumn<double>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _isUnlockedMeta = const VerificationMeta(
    'isUnlocked',
  );
  @override
  late final GeneratedColumn<bool> isUnlocked = GeneratedColumn<bool>(
    'is_unlocked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_unlocked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    badgeKey,
    title,
    description,
    iconName,
    category,
    unlockedAt,
    progress,
    isUnlocked,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_achievements_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserAchievementsLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('badge_key')) {
      context.handle(
        _badgeKeyMeta,
        badgeKey.isAcceptableOrUnknown(data['badge_key']!, _badgeKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_badgeKeyMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('icon_name')) {
      context.handle(
        _iconNameMeta,
        iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    }
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    }
    if (data.containsKey('is_unlocked')) {
      context.handle(
        _isUnlockedMeta,
        isUnlocked.isAcceptableOrUnknown(data['is_unlocked']!, _isUnlockedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserAchievementsLocalData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserAchievementsLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      badgeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}badge_key'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      iconName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlocked_at'],
      ),
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}progress'],
      )!,
      isUnlocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_unlocked'],
      )!,
    );
  }

  @override
  $UserAchievementsLocalTable createAlias(String alias) {
    return $UserAchievementsLocalTable(attachedDatabase, alias);
  }
}

class UserAchievementsLocalData extends DataClass
    implements Insertable<UserAchievementsLocalData> {
  final String id;
  final String userId;
  final String badgeKey;
  final String title;
  final String description;
  final String iconName;
  final String category;
  final DateTime? unlockedAt;
  final double progress;
  final bool isUnlocked;
  const UserAchievementsLocalData({
    required this.id,
    required this.userId,
    required this.badgeKey,
    required this.title,
    required this.description,
    required this.iconName,
    required this.category,
    this.unlockedAt,
    required this.progress,
    required this.isUnlocked,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['badge_key'] = Variable<String>(badgeKey);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['icon_name'] = Variable<String>(iconName);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || unlockedAt != null) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    }
    map['progress'] = Variable<double>(progress);
    map['is_unlocked'] = Variable<bool>(isUnlocked);
    return map;
  }

  UserAchievementsLocalCompanion toCompanion(bool nullToAbsent) {
    return UserAchievementsLocalCompanion(
      id: Value(id),
      userId: Value(userId),
      badgeKey: Value(badgeKey),
      title: Value(title),
      description: Value(description),
      iconName: Value(iconName),
      category: Value(category),
      unlockedAt: unlockedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(unlockedAt),
      progress: Value(progress),
      isUnlocked: Value(isUnlocked),
    );
  }

  factory UserAchievementsLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserAchievementsLocalData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      badgeKey: serializer.fromJson<String>(json['badgeKey']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      iconName: serializer.fromJson<String>(json['iconName']),
      category: serializer.fromJson<String>(json['category']),
      unlockedAt: serializer.fromJson<DateTime?>(json['unlockedAt']),
      progress: serializer.fromJson<double>(json['progress']),
      isUnlocked: serializer.fromJson<bool>(json['isUnlocked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'badgeKey': serializer.toJson<String>(badgeKey),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'iconName': serializer.toJson<String>(iconName),
      'category': serializer.toJson<String>(category),
      'unlockedAt': serializer.toJson<DateTime?>(unlockedAt),
      'progress': serializer.toJson<double>(progress),
      'isUnlocked': serializer.toJson<bool>(isUnlocked),
    };
  }

  UserAchievementsLocalData copyWith({
    String? id,
    String? userId,
    String? badgeKey,
    String? title,
    String? description,
    String? iconName,
    String? category,
    Value<DateTime?> unlockedAt = const Value.absent(),
    double? progress,
    bool? isUnlocked,
  }) => UserAchievementsLocalData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    badgeKey: badgeKey ?? this.badgeKey,
    title: title ?? this.title,
    description: description ?? this.description,
    iconName: iconName ?? this.iconName,
    category: category ?? this.category,
    unlockedAt: unlockedAt.present ? unlockedAt.value : this.unlockedAt,
    progress: progress ?? this.progress,
    isUnlocked: isUnlocked ?? this.isUnlocked,
  );
  UserAchievementsLocalData copyWithCompanion(
    UserAchievementsLocalCompanion data,
  ) {
    return UserAchievementsLocalData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      badgeKey: data.badgeKey.present ? data.badgeKey.value : this.badgeKey,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      category: data.category.present ? data.category.value : this.category,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
      progress: data.progress.present ? data.progress.value : this.progress,
      isUnlocked: data.isUnlocked.present
          ? data.isUnlocked.value
          : this.isUnlocked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserAchievementsLocalData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('badgeKey: $badgeKey, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('iconName: $iconName, ')
          ..write('category: $category, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('progress: $progress, ')
          ..write('isUnlocked: $isUnlocked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    badgeKey,
    title,
    description,
    iconName,
    category,
    unlockedAt,
    progress,
    isUnlocked,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserAchievementsLocalData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.badgeKey == this.badgeKey &&
          other.title == this.title &&
          other.description == this.description &&
          other.iconName == this.iconName &&
          other.category == this.category &&
          other.unlockedAt == this.unlockedAt &&
          other.progress == this.progress &&
          other.isUnlocked == this.isUnlocked);
}

class UserAchievementsLocalCompanion
    extends UpdateCompanion<UserAchievementsLocalData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> badgeKey;
  final Value<String> title;
  final Value<String> description;
  final Value<String> iconName;
  final Value<String> category;
  final Value<DateTime?> unlockedAt;
  final Value<double> progress;
  final Value<bool> isUnlocked;
  final Value<int> rowid;
  const UserAchievementsLocalCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.badgeKey = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.iconName = const Value.absent(),
    this.category = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.progress = const Value.absent(),
    this.isUnlocked = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserAchievementsLocalCompanion.insert({
    required String id,
    required String userId,
    required String badgeKey,
    required String title,
    required String description,
    this.iconName = const Value.absent(),
    this.category = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.progress = const Value.absent(),
    this.isUnlocked = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       badgeKey = Value(badgeKey),
       title = Value(title),
       description = Value(description);
  static Insertable<UserAchievementsLocalData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? badgeKey,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? iconName,
    Expression<String>? category,
    Expression<DateTime>? unlockedAt,
    Expression<double>? progress,
    Expression<bool>? isUnlocked,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (badgeKey != null) 'badge_key': badgeKey,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (iconName != null) 'icon_name': iconName,
      if (category != null) 'category': category,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (progress != null) 'progress': progress,
      if (isUnlocked != null) 'is_unlocked': isUnlocked,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserAchievementsLocalCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? badgeKey,
    Value<String>? title,
    Value<String>? description,
    Value<String>? iconName,
    Value<String>? category,
    Value<DateTime?>? unlockedAt,
    Value<double>? progress,
    Value<bool>? isUnlocked,
    Value<int>? rowid,
  }) {
    return UserAchievementsLocalCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      badgeKey: badgeKey ?? this.badgeKey,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      category: category ?? this.category,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (badgeKey.present) {
      map['badge_key'] = Variable<String>(badgeKey.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    if (progress.present) {
      map['progress'] = Variable<double>(progress.value);
    }
    if (isUnlocked.present) {
      map['is_unlocked'] = Variable<bool>(isUnlocked.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserAchievementsLocalCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('badgeKey: $badgeKey, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('iconName: $iconName, ')
          ..write('category: $category, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('progress: $progress, ')
          ..write('isUnlocked: $isUnlocked, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserActivityDailyLocalTable extends UserActivityDailyLocal
    with TableInfo<$UserActivityDailyLocalTable, UserActivityDailyLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserActivityDailyLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activityDateMeta = const VerificationMeta(
    'activityDate',
  );
  @override
  late final GeneratedColumn<String> activityDate = GeneratedColumn<String>(
    'activity_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _xpEarnedMeta = const VerificationMeta(
    'xpEarned',
  );
  @override
  late final GeneratedColumn<int> xpEarned = GeneratedColumn<int>(
    'xp_earned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _minutesSpentMeta = const VerificationMeta(
    'minutesSpent',
  );
  @override
  late final GeneratedColumn<int> minutesSpent = GeneratedColumn<int>(
    'minutes_spent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sessionsCountMeta = const VerificationMeta(
    'sessionsCount',
  );
  @override
  late final GeneratedColumn<int> sessionsCount = GeneratedColumn<int>(
    'sessions_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _wordsPracticedMeta = const VerificationMeta(
    'wordsPracticed',
  );
  @override
  late final GeneratedColumn<int> wordsPracticed = GeneratedColumn<int>(
    'words_practiced',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _grammarDrillsCountMeta =
      const VerificationMeta('grammarDrillsCount');
  @override
  late final GeneratedColumn<int> grammarDrillsCount = GeneratedColumn<int>(
    'grammar_drills_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    activityDate,
    xpEarned,
    minutesSpent,
    sessionsCount,
    wordsPracticed,
    grammarDrillsCount,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_activity_daily_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserActivityDailyLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('activity_date')) {
      context.handle(
        _activityDateMeta,
        activityDate.isAcceptableOrUnknown(
          data['activity_date']!,
          _activityDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activityDateMeta);
    }
    if (data.containsKey('xp_earned')) {
      context.handle(
        _xpEarnedMeta,
        xpEarned.isAcceptableOrUnknown(data['xp_earned']!, _xpEarnedMeta),
      );
    }
    if (data.containsKey('minutes_spent')) {
      context.handle(
        _minutesSpentMeta,
        minutesSpent.isAcceptableOrUnknown(
          data['minutes_spent']!,
          _minutesSpentMeta,
        ),
      );
    }
    if (data.containsKey('sessions_count')) {
      context.handle(
        _sessionsCountMeta,
        sessionsCount.isAcceptableOrUnknown(
          data['sessions_count']!,
          _sessionsCountMeta,
        ),
      );
    }
    if (data.containsKey('words_practiced')) {
      context.handle(
        _wordsPracticedMeta,
        wordsPracticed.isAcceptableOrUnknown(
          data['words_practiced']!,
          _wordsPracticedMeta,
        ),
      );
    }
    if (data.containsKey('grammar_drills_count')) {
      context.handle(
        _grammarDrillsCountMeta,
        grammarDrillsCount.isAcceptableOrUnknown(
          data['grammar_drills_count']!,
          _grammarDrillsCountMeta,
        ),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserActivityDailyLocalData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserActivityDailyLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      activityDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_date'],
      )!,
      xpEarned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp_earned'],
      )!,
      minutesSpent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minutes_spent'],
      )!,
      sessionsCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sessions_count'],
      )!,
      wordsPracticed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}words_practiced'],
      )!,
      grammarDrillsCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grammar_drills_count'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $UserActivityDailyLocalTable createAlias(String alias) {
    return $UserActivityDailyLocalTable(attachedDatabase, alias);
  }
}

class UserActivityDailyLocalData extends DataClass
    implements Insertable<UserActivityDailyLocalData> {
  final int id;
  final String userId;
  final String activityDate;
  final int xpEarned;
  final int minutesSpent;
  final int sessionsCount;
  final int wordsPracticed;
  final int grammarDrillsCount;
  final bool isSynced;
  const UserActivityDailyLocalData({
    required this.id,
    required this.userId,
    required this.activityDate,
    required this.xpEarned,
    required this.minutesSpent,
    required this.sessionsCount,
    required this.wordsPracticed,
    required this.grammarDrillsCount,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['activity_date'] = Variable<String>(activityDate);
    map['xp_earned'] = Variable<int>(xpEarned);
    map['minutes_spent'] = Variable<int>(minutesSpent);
    map['sessions_count'] = Variable<int>(sessionsCount);
    map['words_practiced'] = Variable<int>(wordsPracticed);
    map['grammar_drills_count'] = Variable<int>(grammarDrillsCount);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  UserActivityDailyLocalCompanion toCompanion(bool nullToAbsent) {
    return UserActivityDailyLocalCompanion(
      id: Value(id),
      userId: Value(userId),
      activityDate: Value(activityDate),
      xpEarned: Value(xpEarned),
      minutesSpent: Value(minutesSpent),
      sessionsCount: Value(sessionsCount),
      wordsPracticed: Value(wordsPracticed),
      grammarDrillsCount: Value(grammarDrillsCount),
      isSynced: Value(isSynced),
    );
  }

  factory UserActivityDailyLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserActivityDailyLocalData(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      activityDate: serializer.fromJson<String>(json['activityDate']),
      xpEarned: serializer.fromJson<int>(json['xpEarned']),
      minutesSpent: serializer.fromJson<int>(json['minutesSpent']),
      sessionsCount: serializer.fromJson<int>(json['sessionsCount']),
      wordsPracticed: serializer.fromJson<int>(json['wordsPracticed']),
      grammarDrillsCount: serializer.fromJson<int>(json['grammarDrillsCount']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'activityDate': serializer.toJson<String>(activityDate),
      'xpEarned': serializer.toJson<int>(xpEarned),
      'minutesSpent': serializer.toJson<int>(minutesSpent),
      'sessionsCount': serializer.toJson<int>(sessionsCount),
      'wordsPracticed': serializer.toJson<int>(wordsPracticed),
      'grammarDrillsCount': serializer.toJson<int>(grammarDrillsCount),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  UserActivityDailyLocalData copyWith({
    int? id,
    String? userId,
    String? activityDate,
    int? xpEarned,
    int? minutesSpent,
    int? sessionsCount,
    int? wordsPracticed,
    int? grammarDrillsCount,
    bool? isSynced,
  }) => UserActivityDailyLocalData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    activityDate: activityDate ?? this.activityDate,
    xpEarned: xpEarned ?? this.xpEarned,
    minutesSpent: minutesSpent ?? this.minutesSpent,
    sessionsCount: sessionsCount ?? this.sessionsCount,
    wordsPracticed: wordsPracticed ?? this.wordsPracticed,
    grammarDrillsCount: grammarDrillsCount ?? this.grammarDrillsCount,
    isSynced: isSynced ?? this.isSynced,
  );
  UserActivityDailyLocalData copyWithCompanion(
    UserActivityDailyLocalCompanion data,
  ) {
    return UserActivityDailyLocalData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      activityDate: data.activityDate.present
          ? data.activityDate.value
          : this.activityDate,
      xpEarned: data.xpEarned.present ? data.xpEarned.value : this.xpEarned,
      minutesSpent: data.minutesSpent.present
          ? data.minutesSpent.value
          : this.minutesSpent,
      sessionsCount: data.sessionsCount.present
          ? data.sessionsCount.value
          : this.sessionsCount,
      wordsPracticed: data.wordsPracticed.present
          ? data.wordsPracticed.value
          : this.wordsPracticed,
      grammarDrillsCount: data.grammarDrillsCount.present
          ? data.grammarDrillsCount.value
          : this.grammarDrillsCount,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserActivityDailyLocalData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('activityDate: $activityDate, ')
          ..write('xpEarned: $xpEarned, ')
          ..write('minutesSpent: $minutesSpent, ')
          ..write('sessionsCount: $sessionsCount, ')
          ..write('wordsPracticed: $wordsPracticed, ')
          ..write('grammarDrillsCount: $grammarDrillsCount, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    activityDate,
    xpEarned,
    minutesSpent,
    sessionsCount,
    wordsPracticed,
    grammarDrillsCount,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserActivityDailyLocalData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.activityDate == this.activityDate &&
          other.xpEarned == this.xpEarned &&
          other.minutesSpent == this.minutesSpent &&
          other.sessionsCount == this.sessionsCount &&
          other.wordsPracticed == this.wordsPracticed &&
          other.grammarDrillsCount == this.grammarDrillsCount &&
          other.isSynced == this.isSynced);
}

class UserActivityDailyLocalCompanion
    extends UpdateCompanion<UserActivityDailyLocalData> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> activityDate;
  final Value<int> xpEarned;
  final Value<int> minutesSpent;
  final Value<int> sessionsCount;
  final Value<int> wordsPracticed;
  final Value<int> grammarDrillsCount;
  final Value<bool> isSynced;
  const UserActivityDailyLocalCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.activityDate = const Value.absent(),
    this.xpEarned = const Value.absent(),
    this.minutesSpent = const Value.absent(),
    this.sessionsCount = const Value.absent(),
    this.wordsPracticed = const Value.absent(),
    this.grammarDrillsCount = const Value.absent(),
    this.isSynced = const Value.absent(),
  });
  UserActivityDailyLocalCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required String activityDate,
    this.xpEarned = const Value.absent(),
    this.minutesSpent = const Value.absent(),
    this.sessionsCount = const Value.absent(),
    this.wordsPracticed = const Value.absent(),
    this.grammarDrillsCount = const Value.absent(),
    this.isSynced = const Value.absent(),
  }) : userId = Value(userId),
       activityDate = Value(activityDate);
  static Insertable<UserActivityDailyLocalData> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? activityDate,
    Expression<int>? xpEarned,
    Expression<int>? minutesSpent,
    Expression<int>? sessionsCount,
    Expression<int>? wordsPracticed,
    Expression<int>? grammarDrillsCount,
    Expression<bool>? isSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (activityDate != null) 'activity_date': activityDate,
      if (xpEarned != null) 'xp_earned': xpEarned,
      if (minutesSpent != null) 'minutes_spent': minutesSpent,
      if (sessionsCount != null) 'sessions_count': sessionsCount,
      if (wordsPracticed != null) 'words_practiced': wordsPracticed,
      if (grammarDrillsCount != null)
        'grammar_drills_count': grammarDrillsCount,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  UserActivityDailyLocalCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? activityDate,
    Value<int>? xpEarned,
    Value<int>? minutesSpent,
    Value<int>? sessionsCount,
    Value<int>? wordsPracticed,
    Value<int>? grammarDrillsCount,
    Value<bool>? isSynced,
  }) {
    return UserActivityDailyLocalCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      activityDate: activityDate ?? this.activityDate,
      xpEarned: xpEarned ?? this.xpEarned,
      minutesSpent: minutesSpent ?? this.minutesSpent,
      sessionsCount: sessionsCount ?? this.sessionsCount,
      wordsPracticed: wordsPracticed ?? this.wordsPracticed,
      grammarDrillsCount: grammarDrillsCount ?? this.grammarDrillsCount,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (activityDate.present) {
      map['activity_date'] = Variable<String>(activityDate.value);
    }
    if (xpEarned.present) {
      map['xp_earned'] = Variable<int>(xpEarned.value);
    }
    if (minutesSpent.present) {
      map['minutes_spent'] = Variable<int>(minutesSpent.value);
    }
    if (sessionsCount.present) {
      map['sessions_count'] = Variable<int>(sessionsCount.value);
    }
    if (wordsPracticed.present) {
      map['words_practiced'] = Variable<int>(wordsPracticed.value);
    }
    if (grammarDrillsCount.present) {
      map['grammar_drills_count'] = Variable<int>(grammarDrillsCount.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserActivityDailyLocalCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('activityDate: $activityDate, ')
          ..write('xpEarned: $xpEarned, ')
          ..write('minutesSpent: $minutesSpent, ')
          ..write('sessionsCount: $sessionsCount, ')
          ..write('wordsPracticed: $wordsPracticed, ')
          ..write('grammarDrillsCount: $grammarDrillsCount, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }
}

class $UserSettingsLocalTable extends UserSettingsLocal
    with TableInfo<$UserSettingsLocalTable, UserSettingsLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('es'),
  );
  static const VerificationMeta _dailyGoalMinutesMeta = const VerificationMeta(
    'dailyGoalMinutes',
  );
  @override
  late final GeneratedColumn<int> dailyGoalMinutes = GeneratedColumn<int>(
    'daily_goal_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(20),
  );
  static const VerificationMeta _targetLevelMeta = const VerificationMeta(
    'targetLevel',
  );
  @override
  late final GeneratedColumn<String> targetLevel = GeneratedColumn<String>(
    'target_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('B2'),
  );
  static const VerificationMeta _notificationsEnabledMeta =
      const VerificationMeta('notificationsEnabled');
  @override
  late final GeneratedColumn<bool> notificationsEnabled = GeneratedColumn<bool>(
    'notifications_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notifications_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    locale,
    dailyGoalMinutes,
    targetLevel,
    notificationsEnabled,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserSettingsLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('locale')) {
      context.handle(
        _localeMeta,
        locale.isAcceptableOrUnknown(data['locale']!, _localeMeta),
      );
    }
    if (data.containsKey('daily_goal_minutes')) {
      context.handle(
        _dailyGoalMinutesMeta,
        dailyGoalMinutes.isAcceptableOrUnknown(
          data['daily_goal_minutes']!,
          _dailyGoalMinutesMeta,
        ),
      );
    }
    if (data.containsKey('target_level')) {
      context.handle(
        _targetLevelMeta,
        targetLevel.isAcceptableOrUnknown(
          data['target_level']!,
          _targetLevelMeta,
        ),
      );
    }
    if (data.containsKey('notifications_enabled')) {
      context.handle(
        _notificationsEnabledMeta,
        notificationsEnabled.isAcceptableOrUnknown(
          data['notifications_enabled']!,
          _notificationsEnabledMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  UserSettingsLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSettingsLocalData(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      )!,
      dailyGoalMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_goal_minutes'],
      )!,
      targetLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_level'],
      )!,
      notificationsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notifications_enabled'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserSettingsLocalTable createAlias(String alias) {
    return $UserSettingsLocalTable(attachedDatabase, alias);
  }
}

class UserSettingsLocalData extends DataClass
    implements Insertable<UserSettingsLocalData> {
  final String userId;
  final String locale;
  final int dailyGoalMinutes;
  final String targetLevel;
  final bool notificationsEnabled;
  final DateTime updatedAt;
  const UserSettingsLocalData({
    required this.userId,
    required this.locale,
    required this.dailyGoalMinutes,
    required this.targetLevel,
    required this.notificationsEnabled,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['locale'] = Variable<String>(locale);
    map['daily_goal_minutes'] = Variable<int>(dailyGoalMinutes);
    map['target_level'] = Variable<String>(targetLevel);
    map['notifications_enabled'] = Variable<bool>(notificationsEnabled);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserSettingsLocalCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsLocalCompanion(
      userId: Value(userId),
      locale: Value(locale),
      dailyGoalMinutes: Value(dailyGoalMinutes),
      targetLevel: Value(targetLevel),
      notificationsEnabled: Value(notificationsEnabled),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserSettingsLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSettingsLocalData(
      userId: serializer.fromJson<String>(json['userId']),
      locale: serializer.fromJson<String>(json['locale']),
      dailyGoalMinutes: serializer.fromJson<int>(json['dailyGoalMinutes']),
      targetLevel: serializer.fromJson<String>(json['targetLevel']),
      notificationsEnabled: serializer.fromJson<bool>(
        json['notificationsEnabled'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'locale': serializer.toJson<String>(locale),
      'dailyGoalMinutes': serializer.toJson<int>(dailyGoalMinutes),
      'targetLevel': serializer.toJson<String>(targetLevel),
      'notificationsEnabled': serializer.toJson<bool>(notificationsEnabled),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserSettingsLocalData copyWith({
    String? userId,
    String? locale,
    int? dailyGoalMinutes,
    String? targetLevel,
    bool? notificationsEnabled,
    DateTime? updatedAt,
  }) => UserSettingsLocalData(
    userId: userId ?? this.userId,
    locale: locale ?? this.locale,
    dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
    targetLevel: targetLevel ?? this.targetLevel,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserSettingsLocalData copyWithCompanion(UserSettingsLocalCompanion data) {
    return UserSettingsLocalData(
      userId: data.userId.present ? data.userId.value : this.userId,
      locale: data.locale.present ? data.locale.value : this.locale,
      dailyGoalMinutes: data.dailyGoalMinutes.present
          ? data.dailyGoalMinutes.value
          : this.dailyGoalMinutes,
      targetLevel: data.targetLevel.present
          ? data.targetLevel.value
          : this.targetLevel,
      notificationsEnabled: data.notificationsEnabled.present
          ? data.notificationsEnabled.value
          : this.notificationsEnabled,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsLocalData(')
          ..write('userId: $userId, ')
          ..write('locale: $locale, ')
          ..write('dailyGoalMinutes: $dailyGoalMinutes, ')
          ..write('targetLevel: $targetLevel, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    locale,
    dailyGoalMinutes,
    targetLevel,
    notificationsEnabled,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSettingsLocalData &&
          other.userId == this.userId &&
          other.locale == this.locale &&
          other.dailyGoalMinutes == this.dailyGoalMinutes &&
          other.targetLevel == this.targetLevel &&
          other.notificationsEnabled == this.notificationsEnabled &&
          other.updatedAt == this.updatedAt);
}

class UserSettingsLocalCompanion
    extends UpdateCompanion<UserSettingsLocalData> {
  final Value<String> userId;
  final Value<String> locale;
  final Value<int> dailyGoalMinutes;
  final Value<String> targetLevel;
  final Value<bool> notificationsEnabled;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UserSettingsLocalCompanion({
    this.userId = const Value.absent(),
    this.locale = const Value.absent(),
    this.dailyGoalMinutes = const Value.absent(),
    this.targetLevel = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserSettingsLocalCompanion.insert({
    required String userId,
    this.locale = const Value.absent(),
    this.dailyGoalMinutes = const Value.absent(),
    this.targetLevel = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       updatedAt = Value(updatedAt);
  static Insertable<UserSettingsLocalData> custom({
    Expression<String>? userId,
    Expression<String>? locale,
    Expression<int>? dailyGoalMinutes,
    Expression<String>? targetLevel,
    Expression<bool>? notificationsEnabled,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (locale != null) 'locale': locale,
      if (dailyGoalMinutes != null) 'daily_goal_minutes': dailyGoalMinutes,
      if (targetLevel != null) 'target_level': targetLevel,
      if (notificationsEnabled != null)
        'notifications_enabled': notificationsEnabled,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserSettingsLocalCompanion copyWith({
    Value<String>? userId,
    Value<String>? locale,
    Value<int>? dailyGoalMinutes,
    Value<String>? targetLevel,
    Value<bool>? notificationsEnabled,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UserSettingsLocalCompanion(
      userId: userId ?? this.userId,
      locale: locale ?? this.locale,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      targetLevel: targetLevel ?? this.targetLevel,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (dailyGoalMinutes.present) {
      map['daily_goal_minutes'] = Variable<int>(dailyGoalMinutes.value);
    }
    if (targetLevel.present) {
      map['target_level'] = Variable<String>(targetLevel.value);
    }
    if (notificationsEnabled.present) {
      map['notifications_enabled'] = Variable<bool>(notificationsEnabled.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsLocalCompanion(')
          ..write('userId: $userId, ')
          ..write('locale: $locale, ')
          ..write('dailyGoalMinutes: $dailyGoalMinutes, ')
          ..write('targetLevel: $targetLevel, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VocabularyProgressLocalTable extends VocabularyProgressLocal
    with TableInfo<$VocabularyProgressLocalTable, VocabularyProgressLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VocabularyProgressLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _packIdMeta = const VerificationMeta('packId');
  @override
  late final GeneratedColumn<String> packId = GeneratedColumn<String>(
    'pack_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<String> wordId = GeneratedColumn<String>(
    'word_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _masteryLevelMeta = const VerificationMeta(
    'masteryLevel',
  );
  @override
  late final GeneratedColumn<int> masteryLevel = GeneratedColumn<int>(
    'mastery_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _reviewCountMeta = const VerificationMeta(
    'reviewCount',
  );
  @override
  late final GeneratedColumn<int> reviewCount = GeneratedColumn<int>(
    'review_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pronunciationScoreMeta =
      const VerificationMeta('pronunciationScore');
  @override
  late final GeneratedColumn<double> pronunciationScore =
      GeneratedColumn<double>(
        'pronunciation_score',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _isMasteredMeta = const VerificationMeta(
    'isMastered',
  );
  @override
  late final GeneratedColumn<bool> isMastered = GeneratedColumn<bool>(
    'is_mastered',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_mastered" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastReviewedAtMeta = const VerificationMeta(
    'lastReviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastReviewedAt =
      GeneratedColumn<DateTime>(
        'last_reviewed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    packId,
    wordId,
    userId,
    masteryLevel,
    reviewCount,
    pronunciationScore,
    isMastered,
    lastReviewedAt,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vocabulary_progress_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<VocabularyProgressLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pack_id')) {
      context.handle(
        _packIdMeta,
        packId.isAcceptableOrUnknown(data['pack_id']!, _packIdMeta),
      );
    } else if (isInserting) {
      context.missing(_packIdMeta);
    }
    if (data.containsKey('word_id')) {
      context.handle(
        _wordIdMeta,
        wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('mastery_level')) {
      context.handle(
        _masteryLevelMeta,
        masteryLevel.isAcceptableOrUnknown(
          data['mastery_level']!,
          _masteryLevelMeta,
        ),
      );
    }
    if (data.containsKey('review_count')) {
      context.handle(
        _reviewCountMeta,
        reviewCount.isAcceptableOrUnknown(
          data['review_count']!,
          _reviewCountMeta,
        ),
      );
    }
    if (data.containsKey('pronunciation_score')) {
      context.handle(
        _pronunciationScoreMeta,
        pronunciationScore.isAcceptableOrUnknown(
          data['pronunciation_score']!,
          _pronunciationScoreMeta,
        ),
      );
    }
    if (data.containsKey('is_mastered')) {
      context.handle(
        _isMasteredMeta,
        isMastered.isAcceptableOrUnknown(data['is_mastered']!, _isMasteredMeta),
      );
    }
    if (data.containsKey('last_reviewed_at')) {
      context.handle(
        _lastReviewedAtMeta,
        lastReviewedAt.isAcceptableOrUnknown(
          data['last_reviewed_at']!,
          _lastReviewedAtMeta,
        ),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VocabularyProgressLocalData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VocabularyProgressLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      packId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pack_id'],
      )!,
      wordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      masteryLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mastery_level'],
      )!,
      reviewCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}review_count'],
      )!,
      pronunciationScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pronunciation_score'],
      )!,
      isMastered: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_mastered'],
      )!,
      lastReviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_reviewed_at'],
      ),
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $VocabularyProgressLocalTable createAlias(String alias) {
    return $VocabularyProgressLocalTable(attachedDatabase, alias);
  }
}

class VocabularyProgressLocalData extends DataClass
    implements Insertable<VocabularyProgressLocalData> {
  final int id;
  final String packId;
  final String wordId;
  final String userId;
  final int masteryLevel;
  final int reviewCount;
  final double pronunciationScore;
  final bool isMastered;
  final DateTime? lastReviewedAt;
  final bool isSynced;
  const VocabularyProgressLocalData({
    required this.id,
    required this.packId,
    required this.wordId,
    required this.userId,
    required this.masteryLevel,
    required this.reviewCount,
    required this.pronunciationScore,
    required this.isMastered,
    this.lastReviewedAt,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pack_id'] = Variable<String>(packId);
    map['word_id'] = Variable<String>(wordId);
    map['user_id'] = Variable<String>(userId);
    map['mastery_level'] = Variable<int>(masteryLevel);
    map['review_count'] = Variable<int>(reviewCount);
    map['pronunciation_score'] = Variable<double>(pronunciationScore);
    map['is_mastered'] = Variable<bool>(isMastered);
    if (!nullToAbsent || lastReviewedAt != null) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  VocabularyProgressLocalCompanion toCompanion(bool nullToAbsent) {
    return VocabularyProgressLocalCompanion(
      id: Value(id),
      packId: Value(packId),
      wordId: Value(wordId),
      userId: Value(userId),
      masteryLevel: Value(masteryLevel),
      reviewCount: Value(reviewCount),
      pronunciationScore: Value(pronunciationScore),
      isMastered: Value(isMastered),
      lastReviewedAt: lastReviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewedAt),
      isSynced: Value(isSynced),
    );
  }

  factory VocabularyProgressLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VocabularyProgressLocalData(
      id: serializer.fromJson<int>(json['id']),
      packId: serializer.fromJson<String>(json['packId']),
      wordId: serializer.fromJson<String>(json['wordId']),
      userId: serializer.fromJson<String>(json['userId']),
      masteryLevel: serializer.fromJson<int>(json['masteryLevel']),
      reviewCount: serializer.fromJson<int>(json['reviewCount']),
      pronunciationScore: serializer.fromJson<double>(
        json['pronunciationScore'],
      ),
      isMastered: serializer.fromJson<bool>(json['isMastered']),
      lastReviewedAt: serializer.fromJson<DateTime?>(json['lastReviewedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'packId': serializer.toJson<String>(packId),
      'wordId': serializer.toJson<String>(wordId),
      'userId': serializer.toJson<String>(userId),
      'masteryLevel': serializer.toJson<int>(masteryLevel),
      'reviewCount': serializer.toJson<int>(reviewCount),
      'pronunciationScore': serializer.toJson<double>(pronunciationScore),
      'isMastered': serializer.toJson<bool>(isMastered),
      'lastReviewedAt': serializer.toJson<DateTime?>(lastReviewedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  VocabularyProgressLocalData copyWith({
    int? id,
    String? packId,
    String? wordId,
    String? userId,
    int? masteryLevel,
    int? reviewCount,
    double? pronunciationScore,
    bool? isMastered,
    Value<DateTime?> lastReviewedAt = const Value.absent(),
    bool? isSynced,
  }) => VocabularyProgressLocalData(
    id: id ?? this.id,
    packId: packId ?? this.packId,
    wordId: wordId ?? this.wordId,
    userId: userId ?? this.userId,
    masteryLevel: masteryLevel ?? this.masteryLevel,
    reviewCount: reviewCount ?? this.reviewCount,
    pronunciationScore: pronunciationScore ?? this.pronunciationScore,
    isMastered: isMastered ?? this.isMastered,
    lastReviewedAt: lastReviewedAt.present
        ? lastReviewedAt.value
        : this.lastReviewedAt,
    isSynced: isSynced ?? this.isSynced,
  );
  VocabularyProgressLocalData copyWithCompanion(
    VocabularyProgressLocalCompanion data,
  ) {
    return VocabularyProgressLocalData(
      id: data.id.present ? data.id.value : this.id,
      packId: data.packId.present ? data.packId.value : this.packId,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      userId: data.userId.present ? data.userId.value : this.userId,
      masteryLevel: data.masteryLevel.present
          ? data.masteryLevel.value
          : this.masteryLevel,
      reviewCount: data.reviewCount.present
          ? data.reviewCount.value
          : this.reviewCount,
      pronunciationScore: data.pronunciationScore.present
          ? data.pronunciationScore.value
          : this.pronunciationScore,
      isMastered: data.isMastered.present
          ? data.isMastered.value
          : this.isMastered,
      lastReviewedAt: data.lastReviewedAt.present
          ? data.lastReviewedAt.value
          : this.lastReviewedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VocabularyProgressLocalData(')
          ..write('id: $id, ')
          ..write('packId: $packId, ')
          ..write('wordId: $wordId, ')
          ..write('userId: $userId, ')
          ..write('masteryLevel: $masteryLevel, ')
          ..write('reviewCount: $reviewCount, ')
          ..write('pronunciationScore: $pronunciationScore, ')
          ..write('isMastered: $isMastered, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    packId,
    wordId,
    userId,
    masteryLevel,
    reviewCount,
    pronunciationScore,
    isMastered,
    lastReviewedAt,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VocabularyProgressLocalData &&
          other.id == this.id &&
          other.packId == this.packId &&
          other.wordId == this.wordId &&
          other.userId == this.userId &&
          other.masteryLevel == this.masteryLevel &&
          other.reviewCount == this.reviewCount &&
          other.pronunciationScore == this.pronunciationScore &&
          other.isMastered == this.isMastered &&
          other.lastReviewedAt == this.lastReviewedAt &&
          other.isSynced == this.isSynced);
}

class VocabularyProgressLocalCompanion
    extends UpdateCompanion<VocabularyProgressLocalData> {
  final Value<int> id;
  final Value<String> packId;
  final Value<String> wordId;
  final Value<String> userId;
  final Value<int> masteryLevel;
  final Value<int> reviewCount;
  final Value<double> pronunciationScore;
  final Value<bool> isMastered;
  final Value<DateTime?> lastReviewedAt;
  final Value<bool> isSynced;
  const VocabularyProgressLocalCompanion({
    this.id = const Value.absent(),
    this.packId = const Value.absent(),
    this.wordId = const Value.absent(),
    this.userId = const Value.absent(),
    this.masteryLevel = const Value.absent(),
    this.reviewCount = const Value.absent(),
    this.pronunciationScore = const Value.absent(),
    this.isMastered = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
  });
  VocabularyProgressLocalCompanion.insert({
    this.id = const Value.absent(),
    required String packId,
    required String wordId,
    required String userId,
    this.masteryLevel = const Value.absent(),
    this.reviewCount = const Value.absent(),
    this.pronunciationScore = const Value.absent(),
    this.isMastered = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
  }) : packId = Value(packId),
       wordId = Value(wordId),
       userId = Value(userId);
  static Insertable<VocabularyProgressLocalData> custom({
    Expression<int>? id,
    Expression<String>? packId,
    Expression<String>? wordId,
    Expression<String>? userId,
    Expression<int>? masteryLevel,
    Expression<int>? reviewCount,
    Expression<double>? pronunciationScore,
    Expression<bool>? isMastered,
    Expression<DateTime>? lastReviewedAt,
    Expression<bool>? isSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (packId != null) 'pack_id': packId,
      if (wordId != null) 'word_id': wordId,
      if (userId != null) 'user_id': userId,
      if (masteryLevel != null) 'mastery_level': masteryLevel,
      if (reviewCount != null) 'review_count': reviewCount,
      if (pronunciationScore != null) 'pronunciation_score': pronunciationScore,
      if (isMastered != null) 'is_mastered': isMastered,
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  VocabularyProgressLocalCompanion copyWith({
    Value<int>? id,
    Value<String>? packId,
    Value<String>? wordId,
    Value<String>? userId,
    Value<int>? masteryLevel,
    Value<int>? reviewCount,
    Value<double>? pronunciationScore,
    Value<bool>? isMastered,
    Value<DateTime?>? lastReviewedAt,
    Value<bool>? isSynced,
  }) {
    return VocabularyProgressLocalCompanion(
      id: id ?? this.id,
      packId: packId ?? this.packId,
      wordId: wordId ?? this.wordId,
      userId: userId ?? this.userId,
      masteryLevel: masteryLevel ?? this.masteryLevel,
      reviewCount: reviewCount ?? this.reviewCount,
      pronunciationScore: pronunciationScore ?? this.pronunciationScore,
      isMastered: isMastered ?? this.isMastered,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (packId.present) {
      map['pack_id'] = Variable<String>(packId.value);
    }
    if (wordId.present) {
      map['word_id'] = Variable<String>(wordId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (masteryLevel.present) {
      map['mastery_level'] = Variable<int>(masteryLevel.value);
    }
    if (reviewCount.present) {
      map['review_count'] = Variable<int>(reviewCount.value);
    }
    if (pronunciationScore.present) {
      map['pronunciation_score'] = Variable<double>(pronunciationScore.value);
    }
    if (isMastered.present) {
      map['is_mastered'] = Variable<bool>(isMastered.value);
    }
    if (lastReviewedAt.present) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VocabularyProgressLocalCompanion(')
          ..write('id: $id, ')
          ..write('packId: $packId, ')
          ..write('wordId: $wordId, ')
          ..write('userId: $userId, ')
          ..write('masteryLevel: $masteryLevel, ')
          ..write('reviewCount: $reviewCount, ')
          ..write('pronunciationScore: $pronunciationScore, ')
          ..write('isMastered: $isMastered, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }
}

class $GrammarProgressLocalTable extends GrammarProgressLocal
    with TableInfo<$GrammarProgressLocalTable, GrammarProgressLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GrammarProgressLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _unitIdMeta = const VerificationMeta('unitId');
  @override
  late final GeneratedColumn<String> unitId = GeneratedColumn<String>(
    'unit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsCountMeta = const VerificationMeta(
    'attemptsCount',
  );
  @override
  late final GeneratedColumn<int> attemptsCount = GeneratedColumn<int>(
    'attempts_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bestScoreMeta = const VerificationMeta(
    'bestScore',
  );
  @override
  late final GeneratedColumn<double> bestScore = GeneratedColumn<double>(
    'best_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _lastScoreMeta = const VerificationMeta(
    'lastScore',
  );
  @override
  late final GeneratedColumn<double> lastScore = GeneratedColumn<double>(
    'last_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    unitId,
    userId,
    attemptsCount,
    bestScore,
    lastScore,
    isCompleted,
    completedAt,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grammar_progress_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<GrammarProgressLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('unit_id')) {
      context.handle(
        _unitIdMeta,
        unitId.isAcceptableOrUnknown(data['unit_id']!, _unitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_unitIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('attempts_count')) {
      context.handle(
        _attemptsCountMeta,
        attemptsCount.isAcceptableOrUnknown(
          data['attempts_count']!,
          _attemptsCountMeta,
        ),
      );
    }
    if (data.containsKey('best_score')) {
      context.handle(
        _bestScoreMeta,
        bestScore.isAcceptableOrUnknown(data['best_score']!, _bestScoreMeta),
      );
    }
    if (data.containsKey('last_score')) {
      context.handle(
        _lastScoreMeta,
        lastScore.isAcceptableOrUnknown(data['last_score']!, _lastScoreMeta),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GrammarProgressLocalData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GrammarProgressLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      unitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      attemptsCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts_count'],
      )!,
      bestScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}best_score'],
      )!,
      lastScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}last_score'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $GrammarProgressLocalTable createAlias(String alias) {
    return $GrammarProgressLocalTable(attachedDatabase, alias);
  }
}

class GrammarProgressLocalData extends DataClass
    implements Insertable<GrammarProgressLocalData> {
  final int id;
  final String unitId;
  final String userId;
  final int attemptsCount;
  final double bestScore;
  final double lastScore;
  final bool isCompleted;
  final DateTime? completedAt;
  final bool isSynced;
  const GrammarProgressLocalData({
    required this.id,
    required this.unitId,
    required this.userId,
    required this.attemptsCount,
    required this.bestScore,
    required this.lastScore,
    required this.isCompleted,
    this.completedAt,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['unit_id'] = Variable<String>(unitId);
    map['user_id'] = Variable<String>(userId);
    map['attempts_count'] = Variable<int>(attemptsCount);
    map['best_score'] = Variable<double>(bestScore);
    map['last_score'] = Variable<double>(lastScore);
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  GrammarProgressLocalCompanion toCompanion(bool nullToAbsent) {
    return GrammarProgressLocalCompanion(
      id: Value(id),
      unitId: Value(unitId),
      userId: Value(userId),
      attemptsCount: Value(attemptsCount),
      bestScore: Value(bestScore),
      lastScore: Value(lastScore),
      isCompleted: Value(isCompleted),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      isSynced: Value(isSynced),
    );
  }

  factory GrammarProgressLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GrammarProgressLocalData(
      id: serializer.fromJson<int>(json['id']),
      unitId: serializer.fromJson<String>(json['unitId']),
      userId: serializer.fromJson<String>(json['userId']),
      attemptsCount: serializer.fromJson<int>(json['attemptsCount']),
      bestScore: serializer.fromJson<double>(json['bestScore']),
      lastScore: serializer.fromJson<double>(json['lastScore']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'unitId': serializer.toJson<String>(unitId),
      'userId': serializer.toJson<String>(userId),
      'attemptsCount': serializer.toJson<int>(attemptsCount),
      'bestScore': serializer.toJson<double>(bestScore),
      'lastScore': serializer.toJson<double>(lastScore),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  GrammarProgressLocalData copyWith({
    int? id,
    String? unitId,
    String? userId,
    int? attemptsCount,
    double? bestScore,
    double? lastScore,
    bool? isCompleted,
    Value<DateTime?> completedAt = const Value.absent(),
    bool? isSynced,
  }) => GrammarProgressLocalData(
    id: id ?? this.id,
    unitId: unitId ?? this.unitId,
    userId: userId ?? this.userId,
    attemptsCount: attemptsCount ?? this.attemptsCount,
    bestScore: bestScore ?? this.bestScore,
    lastScore: lastScore ?? this.lastScore,
    isCompleted: isCompleted ?? this.isCompleted,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    isSynced: isSynced ?? this.isSynced,
  );
  GrammarProgressLocalData copyWithCompanion(
    GrammarProgressLocalCompanion data,
  ) {
    return GrammarProgressLocalData(
      id: data.id.present ? data.id.value : this.id,
      unitId: data.unitId.present ? data.unitId.value : this.unitId,
      userId: data.userId.present ? data.userId.value : this.userId,
      attemptsCount: data.attemptsCount.present
          ? data.attemptsCount.value
          : this.attemptsCount,
      bestScore: data.bestScore.present ? data.bestScore.value : this.bestScore,
      lastScore: data.lastScore.present ? data.lastScore.value : this.lastScore,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GrammarProgressLocalData(')
          ..write('id: $id, ')
          ..write('unitId: $unitId, ')
          ..write('userId: $userId, ')
          ..write('attemptsCount: $attemptsCount, ')
          ..write('bestScore: $bestScore, ')
          ..write('lastScore: $lastScore, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    unitId,
    userId,
    attemptsCount,
    bestScore,
    lastScore,
    isCompleted,
    completedAt,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GrammarProgressLocalData &&
          other.id == this.id &&
          other.unitId == this.unitId &&
          other.userId == this.userId &&
          other.attemptsCount == this.attemptsCount &&
          other.bestScore == this.bestScore &&
          other.lastScore == this.lastScore &&
          other.isCompleted == this.isCompleted &&
          other.completedAt == this.completedAt &&
          other.isSynced == this.isSynced);
}

class GrammarProgressLocalCompanion
    extends UpdateCompanion<GrammarProgressLocalData> {
  final Value<int> id;
  final Value<String> unitId;
  final Value<String> userId;
  final Value<int> attemptsCount;
  final Value<double> bestScore;
  final Value<double> lastScore;
  final Value<bool> isCompleted;
  final Value<DateTime?> completedAt;
  final Value<bool> isSynced;
  const GrammarProgressLocalCompanion({
    this.id = const Value.absent(),
    this.unitId = const Value.absent(),
    this.userId = const Value.absent(),
    this.attemptsCount = const Value.absent(),
    this.bestScore = const Value.absent(),
    this.lastScore = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
  });
  GrammarProgressLocalCompanion.insert({
    this.id = const Value.absent(),
    required String unitId,
    required String userId,
    this.attemptsCount = const Value.absent(),
    this.bestScore = const Value.absent(),
    this.lastScore = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
  }) : unitId = Value(unitId),
       userId = Value(userId);
  static Insertable<GrammarProgressLocalData> custom({
    Expression<int>? id,
    Expression<String>? unitId,
    Expression<String>? userId,
    Expression<int>? attemptsCount,
    Expression<double>? bestScore,
    Expression<double>? lastScore,
    Expression<bool>? isCompleted,
    Expression<DateTime>? completedAt,
    Expression<bool>? isSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (unitId != null) 'unit_id': unitId,
      if (userId != null) 'user_id': userId,
      if (attemptsCount != null) 'attempts_count': attemptsCount,
      if (bestScore != null) 'best_score': bestScore,
      if (lastScore != null) 'last_score': lastScore,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (completedAt != null) 'completed_at': completedAt,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  GrammarProgressLocalCompanion copyWith({
    Value<int>? id,
    Value<String>? unitId,
    Value<String>? userId,
    Value<int>? attemptsCount,
    Value<double>? bestScore,
    Value<double>? lastScore,
    Value<bool>? isCompleted,
    Value<DateTime?>? completedAt,
    Value<bool>? isSynced,
  }) {
    return GrammarProgressLocalCompanion(
      id: id ?? this.id,
      unitId: unitId ?? this.unitId,
      userId: userId ?? this.userId,
      attemptsCount: attemptsCount ?? this.attemptsCount,
      bestScore: bestScore ?? this.bestScore,
      lastScore: lastScore ?? this.lastScore,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (unitId.present) {
      map['unit_id'] = Variable<String>(unitId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (attemptsCount.present) {
      map['attempts_count'] = Variable<int>(attemptsCount.value);
    }
    if (bestScore.present) {
      map['best_score'] = Variable<double>(bestScore.value);
    }
    if (lastScore.present) {
      map['last_score'] = Variable<double>(lastScore.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GrammarProgressLocalCompanion(')
          ..write('id: $id, ')
          ..write('unitId: $unitId, ')
          ..write('userId: $userId, ')
          ..write('attemptsCount: $attemptsCount, ')
          ..write('bestScore: $bestScore, ')
          ..write('lastScore: $lastScore, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }
}

class $OfflineEventsLocalTable extends OfflineEventsLocal
    with TableInfo<$OfflineEventsLocalTable, OfflineEventsLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfflineEventsLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    eventType,
    payloadJson,
    userId,
    createdAt,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'offline_events_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<OfflineEventsLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OfflineEventsLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfflineEventsLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $OfflineEventsLocalTable createAlias(String alias) {
    return $OfflineEventsLocalTable(attachedDatabase, alias);
  }
}

class OfflineEventsLocalData extends DataClass
    implements Insertable<OfflineEventsLocalData> {
  final int id;
  final String eventType;
  final String payloadJson;
  final String userId;
  final DateTime createdAt;
  final bool isSynced;
  const OfflineEventsLocalData({
    required this.id,
    required this.eventType,
    required this.payloadJson,
    required this.userId,
    required this.createdAt,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['event_type'] = Variable<String>(eventType);
    map['payload_json'] = Variable<String>(payloadJson);
    map['user_id'] = Variable<String>(userId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  OfflineEventsLocalCompanion toCompanion(bool nullToAbsent) {
    return OfflineEventsLocalCompanion(
      id: Value(id),
      eventType: Value(eventType),
      payloadJson: Value(payloadJson),
      userId: Value(userId),
      createdAt: Value(createdAt),
      isSynced: Value(isSynced),
    );
  }

  factory OfflineEventsLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfflineEventsLocalData(
      id: serializer.fromJson<int>(json['id']),
      eventType: serializer.fromJson<String>(json['eventType']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      userId: serializer.fromJson<String>(json['userId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'eventType': serializer.toJson<String>(eventType),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'userId': serializer.toJson<String>(userId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  OfflineEventsLocalData copyWith({
    int? id,
    String? eventType,
    String? payloadJson,
    String? userId,
    DateTime? createdAt,
    bool? isSynced,
  }) => OfflineEventsLocalData(
    id: id ?? this.id,
    eventType: eventType ?? this.eventType,
    payloadJson: payloadJson ?? this.payloadJson,
    userId: userId ?? this.userId,
    createdAt: createdAt ?? this.createdAt,
    isSynced: isSynced ?? this.isSynced,
  );
  OfflineEventsLocalData copyWithCompanion(OfflineEventsLocalCompanion data) {
    return OfflineEventsLocalData(
      id: data.id.present ? data.id.value : this.id,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfflineEventsLocalData(')
          ..write('id: $id, ')
          ..write('eventType: $eventType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, eventType, payloadJson, userId, createdAt, isSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfflineEventsLocalData &&
          other.id == this.id &&
          other.eventType == this.eventType &&
          other.payloadJson == this.payloadJson &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.isSynced == this.isSynced);
}

class OfflineEventsLocalCompanion
    extends UpdateCompanion<OfflineEventsLocalData> {
  final Value<int> id;
  final Value<String> eventType;
  final Value<String> payloadJson;
  final Value<String> userId;
  final Value<DateTime> createdAt;
  final Value<bool> isSynced;
  const OfflineEventsLocalCompanion({
    this.id = const Value.absent(),
    this.eventType = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
  });
  OfflineEventsLocalCompanion.insert({
    this.id = const Value.absent(),
    required String eventType,
    required String payloadJson,
    required String userId,
    required DateTime createdAt,
    this.isSynced = const Value.absent(),
  }) : eventType = Value(eventType),
       payloadJson = Value(payloadJson),
       userId = Value(userId),
       createdAt = Value(createdAt);
  static Insertable<OfflineEventsLocalData> custom({
    Expression<int>? id,
    Expression<String>? eventType,
    Expression<String>? payloadJson,
    Expression<String>? userId,
    Expression<DateTime>? createdAt,
    Expression<bool>? isSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventType != null) 'event_type': eventType,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  OfflineEventsLocalCompanion copyWith({
    Value<int>? id,
    Value<String>? eventType,
    Value<String>? payloadJson,
    Value<String>? userId,
    Value<DateTime>? createdAt,
    Value<bool>? isSynced,
  }) {
    return OfflineEventsLocalCompanion(
      id: id ?? this.id,
      eventType: eventType ?? this.eventType,
      payloadJson: payloadJson ?? this.payloadJson,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfflineEventsLocalCompanion(')
          ..write('id: $id, ')
          ..write('eventType: $eventType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }
}

class $UnitProgressLocalTable extends UnitProgressLocal
    with TableInfo<$UnitProgressLocalTable, UnitProgressLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnitProgressLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trackMeta = const VerificationMeta('track');
  @override
  late final GeneratedColumn<String> track = GeneratedColumn<String>(
    'track',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _objectiveIdMeta = const VerificationMeta(
    'objectiveId',
  );
  @override
  late final GeneratedColumn<String> objectiveId = GeneratedColumn<String>(
    'objective_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _masteryScoreMeta = const VerificationMeta(
    'masteryScore',
  );
  @override
  late final GeneratedColumn<double> masteryScore = GeneratedColumn<double>(
    'mastery_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('new'),
  );
  static const VerificationMeta _lastPracticedAtMeta = const VerificationMeta(
    'lastPracticedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPracticedAt =
      GeneratedColumn<DateTime>(
        'last_practiced_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _streakMeta = const VerificationMeta('streak');
  @override
  late final GeneratedColumn<int> streak = GeneratedColumn<int>(
    'streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    track,
    objectiveId,
    masteryScore,
    attempts,
    state,
    lastPracticedAt,
    streak,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'unit_progress_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<UnitProgressLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('track')) {
      context.handle(
        _trackMeta,
        track.isAcceptableOrUnknown(data['track']!, _trackMeta),
      );
    } else if (isInserting) {
      context.missing(_trackMeta);
    }
    if (data.containsKey('objective_id')) {
      context.handle(
        _objectiveIdMeta,
        objectiveId.isAcceptableOrUnknown(
          data['objective_id']!,
          _objectiveIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_objectiveIdMeta);
    }
    if (data.containsKey('mastery_score')) {
      context.handle(
        _masteryScoreMeta,
        masteryScore.isAcceptableOrUnknown(
          data['mastery_score']!,
          _masteryScoreMeta,
        ),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('last_practiced_at')) {
      context.handle(
        _lastPracticedAtMeta,
        lastPracticedAt.isAcceptableOrUnknown(
          data['last_practiced_at']!,
          _lastPracticedAtMeta,
        ),
      );
    }
    if (data.containsKey('streak')) {
      context.handle(
        _streakMeta,
        streak.isAcceptableOrUnknown(data['streak']!, _streakMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UnitProgressLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UnitProgressLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      track: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track'],
      )!,
      objectiveId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}objective_id'],
      )!,
      masteryScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}mastery_score'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      lastPracticedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_practiced_at'],
      ),
      streak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}streak'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $UnitProgressLocalTable createAlias(String alias) {
    return $UnitProgressLocalTable(attachedDatabase, alias);
  }
}

class UnitProgressLocalData extends DataClass
    implements Insertable<UnitProgressLocalData> {
  final int id;
  final String userId;
  final String track;
  final String objectiveId;
  final double masteryScore;
  final int attempts;
  final String state;
  final DateTime? lastPracticedAt;
  final int streak;
  final bool isSynced;
  const UnitProgressLocalData({
    required this.id,
    required this.userId,
    required this.track,
    required this.objectiveId,
    required this.masteryScore,
    required this.attempts,
    required this.state,
    this.lastPracticedAt,
    required this.streak,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['track'] = Variable<String>(track);
    map['objective_id'] = Variable<String>(objectiveId);
    map['mastery_score'] = Variable<double>(masteryScore);
    map['attempts'] = Variable<int>(attempts);
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || lastPracticedAt != null) {
      map['last_practiced_at'] = Variable<DateTime>(lastPracticedAt);
    }
    map['streak'] = Variable<int>(streak);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  UnitProgressLocalCompanion toCompanion(bool nullToAbsent) {
    return UnitProgressLocalCompanion(
      id: Value(id),
      userId: Value(userId),
      track: Value(track),
      objectiveId: Value(objectiveId),
      masteryScore: Value(masteryScore),
      attempts: Value(attempts),
      state: Value(state),
      lastPracticedAt: lastPracticedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPracticedAt),
      streak: Value(streak),
      isSynced: Value(isSynced),
    );
  }

  factory UnitProgressLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UnitProgressLocalData(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      track: serializer.fromJson<String>(json['track']),
      objectiveId: serializer.fromJson<String>(json['objectiveId']),
      masteryScore: serializer.fromJson<double>(json['masteryScore']),
      attempts: serializer.fromJson<int>(json['attempts']),
      state: serializer.fromJson<String>(json['state']),
      lastPracticedAt: serializer.fromJson<DateTime?>(json['lastPracticedAt']),
      streak: serializer.fromJson<int>(json['streak']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'track': serializer.toJson<String>(track),
      'objectiveId': serializer.toJson<String>(objectiveId),
      'masteryScore': serializer.toJson<double>(masteryScore),
      'attempts': serializer.toJson<int>(attempts),
      'state': serializer.toJson<String>(state),
      'lastPracticedAt': serializer.toJson<DateTime?>(lastPracticedAt),
      'streak': serializer.toJson<int>(streak),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  UnitProgressLocalData copyWith({
    int? id,
    String? userId,
    String? track,
    String? objectiveId,
    double? masteryScore,
    int? attempts,
    String? state,
    Value<DateTime?> lastPracticedAt = const Value.absent(),
    int? streak,
    bool? isSynced,
  }) => UnitProgressLocalData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    track: track ?? this.track,
    objectiveId: objectiveId ?? this.objectiveId,
    masteryScore: masteryScore ?? this.masteryScore,
    attempts: attempts ?? this.attempts,
    state: state ?? this.state,
    lastPracticedAt: lastPracticedAt.present
        ? lastPracticedAt.value
        : this.lastPracticedAt,
    streak: streak ?? this.streak,
    isSynced: isSynced ?? this.isSynced,
  );
  UnitProgressLocalData copyWithCompanion(UnitProgressLocalCompanion data) {
    return UnitProgressLocalData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      track: data.track.present ? data.track.value : this.track,
      objectiveId: data.objectiveId.present
          ? data.objectiveId.value
          : this.objectiveId,
      masteryScore: data.masteryScore.present
          ? data.masteryScore.value
          : this.masteryScore,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      state: data.state.present ? data.state.value : this.state,
      lastPracticedAt: data.lastPracticedAt.present
          ? data.lastPracticedAt.value
          : this.lastPracticedAt,
      streak: data.streak.present ? data.streak.value : this.streak,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UnitProgressLocalData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('track: $track, ')
          ..write('objectiveId: $objectiveId, ')
          ..write('masteryScore: $masteryScore, ')
          ..write('attempts: $attempts, ')
          ..write('state: $state, ')
          ..write('lastPracticedAt: $lastPracticedAt, ')
          ..write('streak: $streak, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    track,
    objectiveId,
    masteryScore,
    attempts,
    state,
    lastPracticedAt,
    streak,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UnitProgressLocalData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.track == this.track &&
          other.objectiveId == this.objectiveId &&
          other.masteryScore == this.masteryScore &&
          other.attempts == this.attempts &&
          other.state == this.state &&
          other.lastPracticedAt == this.lastPracticedAt &&
          other.streak == this.streak &&
          other.isSynced == this.isSynced);
}

class UnitProgressLocalCompanion
    extends UpdateCompanion<UnitProgressLocalData> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> track;
  final Value<String> objectiveId;
  final Value<double> masteryScore;
  final Value<int> attempts;
  final Value<String> state;
  final Value<DateTime?> lastPracticedAt;
  final Value<int> streak;
  final Value<bool> isSynced;
  const UnitProgressLocalCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.track = const Value.absent(),
    this.objectiveId = const Value.absent(),
    this.masteryScore = const Value.absent(),
    this.attempts = const Value.absent(),
    this.state = const Value.absent(),
    this.lastPracticedAt = const Value.absent(),
    this.streak = const Value.absent(),
    this.isSynced = const Value.absent(),
  });
  UnitProgressLocalCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required String track,
    required String objectiveId,
    this.masteryScore = const Value.absent(),
    this.attempts = const Value.absent(),
    this.state = const Value.absent(),
    this.lastPracticedAt = const Value.absent(),
    this.streak = const Value.absent(),
    this.isSynced = const Value.absent(),
  }) : userId = Value(userId),
       track = Value(track),
       objectiveId = Value(objectiveId);
  static Insertable<UnitProgressLocalData> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? track,
    Expression<String>? objectiveId,
    Expression<double>? masteryScore,
    Expression<int>? attempts,
    Expression<String>? state,
    Expression<DateTime>? lastPracticedAt,
    Expression<int>? streak,
    Expression<bool>? isSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (track != null) 'track': track,
      if (objectiveId != null) 'objective_id': objectiveId,
      if (masteryScore != null) 'mastery_score': masteryScore,
      if (attempts != null) 'attempts': attempts,
      if (state != null) 'state': state,
      if (lastPracticedAt != null) 'last_practiced_at': lastPracticedAt,
      if (streak != null) 'streak': streak,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  UnitProgressLocalCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? track,
    Value<String>? objectiveId,
    Value<double>? masteryScore,
    Value<int>? attempts,
    Value<String>? state,
    Value<DateTime?>? lastPracticedAt,
    Value<int>? streak,
    Value<bool>? isSynced,
  }) {
    return UnitProgressLocalCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      track: track ?? this.track,
      objectiveId: objectiveId ?? this.objectiveId,
      masteryScore: masteryScore ?? this.masteryScore,
      attempts: attempts ?? this.attempts,
      state: state ?? this.state,
      lastPracticedAt: lastPracticedAt ?? this.lastPracticedAt,
      streak: streak ?? this.streak,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (track.present) {
      map['track'] = Variable<String>(track.value);
    }
    if (objectiveId.present) {
      map['objective_id'] = Variable<String>(objectiveId.value);
    }
    if (masteryScore.present) {
      map['mastery_score'] = Variable<double>(masteryScore.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (lastPracticedAt.present) {
      map['last_practiced_at'] = Variable<DateTime>(lastPracticedAt.value);
    }
    if (streak.present) {
      map['streak'] = Variable<int>(streak.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UnitProgressLocalCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('track: $track, ')
          ..write('objectiveId: $objectiveId, ')
          ..write('masteryScore: $masteryScore, ')
          ..write('attempts: $attempts, ')
          ..write('state: $state, ')
          ..write('lastPracticedAt: $lastPracticedAt, ')
          ..write('streak: $streak, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }
}

class $PracticeAttemptsLocalTable extends PracticeAttemptsLocal
    with TableInfo<$PracticeAttemptsLocalTable, PracticeAttemptsLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PracticeAttemptsLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _objectiveIdMeta = const VerificationMeta(
    'objectiveId',
  );
  @override
  late final GeneratedColumn<String> objectiveId = GeneratedColumn<String>(
    'objective_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scenarioMeta = const VerificationMeta(
    'scenario',
  );
  @override
  late final GeneratedColumn<String> scenario = GeneratedColumn<String>(
    'scenario',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _difficultyBandMeta = const VerificationMeta(
    'difficultyBand',
  );
  @override
  late final GeneratedColumn<String> difficultyBand = GeneratedColumn<String>(
    'difficulty_band',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trackMeta = const VerificationMeta('track');
  @override
  late final GeneratedColumn<String> track = GeneratedColumn<String>(
    'track',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<double> score = GeneratedColumn<double>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _mistakesMeta = const VerificationMeta(
    'mistakes',
  );
  @override
  late final GeneratedColumn<int> mistakes = GeneratedColumn<int>(
    'mistakes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _repeatedItemsMeta = const VerificationMeta(
    'repeatedItems',
  );
  @override
  late final GeneratedColumn<int> repeatedItems = GeneratedColumn<int>(
    'repeated_items',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _fsrsGeneratedMeta = const VerificationMeta(
    'fsrsGenerated',
  );
  @override
  late final GeneratedColumn<int> fsrsGenerated = GeneratedColumn<int>(
    'fsrs_generated',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    objectiveId,
    scenario,
    difficultyBand,
    track,
    score,
    durationSeconds,
    mistakes,
    repeatedItems,
    fsrsGenerated,
    createdAt,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'practice_attempts_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<PracticeAttemptsLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('objective_id')) {
      context.handle(
        _objectiveIdMeta,
        objectiveId.isAcceptableOrUnknown(
          data['objective_id']!,
          _objectiveIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_objectiveIdMeta);
    }
    if (data.containsKey('scenario')) {
      context.handle(
        _scenarioMeta,
        scenario.isAcceptableOrUnknown(data['scenario']!, _scenarioMeta),
      );
    }
    if (data.containsKey('difficulty_band')) {
      context.handle(
        _difficultyBandMeta,
        difficultyBand.isAcceptableOrUnknown(
          data['difficulty_band']!,
          _difficultyBandMeta,
        ),
      );
    }
    if (data.containsKey('track')) {
      context.handle(
        _trackMeta,
        track.isAcceptableOrUnknown(data['track']!, _trackMeta),
      );
    } else if (isInserting) {
      context.missing(_trackMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('mistakes')) {
      context.handle(
        _mistakesMeta,
        mistakes.isAcceptableOrUnknown(data['mistakes']!, _mistakesMeta),
      );
    }
    if (data.containsKey('repeated_items')) {
      context.handle(
        _repeatedItemsMeta,
        repeatedItems.isAcceptableOrUnknown(
          data['repeated_items']!,
          _repeatedItemsMeta,
        ),
      );
    }
    if (data.containsKey('fsrs_generated')) {
      context.handle(
        _fsrsGeneratedMeta,
        fsrsGenerated.isAcceptableOrUnknown(
          data['fsrs_generated']!,
          _fsrsGeneratedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PracticeAttemptsLocalData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PracticeAttemptsLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      objectiveId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}objective_id'],
      )!,
      scenario: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scenario'],
      ),
      difficultyBand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}difficulty_band'],
      ),
      track: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}score'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      mistakes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mistakes'],
      )!,
      repeatedItems: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repeated_items'],
      )!,
      fsrsGenerated: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fsrs_generated'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $PracticeAttemptsLocalTable createAlias(String alias) {
    return $PracticeAttemptsLocalTable(attachedDatabase, alias);
  }
}

class PracticeAttemptsLocalData extends DataClass
    implements Insertable<PracticeAttemptsLocalData> {
  final int id;
  final String userId;
  final String objectiveId;
  final String? scenario;
  final String? difficultyBand;
  final String track;
  final double score;
  final int durationSeconds;
  final int mistakes;
  final int repeatedItems;
  final int fsrsGenerated;
  final DateTime createdAt;
  final bool isSynced;
  const PracticeAttemptsLocalData({
    required this.id,
    required this.userId,
    required this.objectiveId,
    this.scenario,
    this.difficultyBand,
    required this.track,
    required this.score,
    required this.durationSeconds,
    required this.mistakes,
    required this.repeatedItems,
    required this.fsrsGenerated,
    required this.createdAt,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['objective_id'] = Variable<String>(objectiveId);
    if (!nullToAbsent || scenario != null) {
      map['scenario'] = Variable<String>(scenario);
    }
    if (!nullToAbsent || difficultyBand != null) {
      map['difficulty_band'] = Variable<String>(difficultyBand);
    }
    map['track'] = Variable<String>(track);
    map['score'] = Variable<double>(score);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['mistakes'] = Variable<int>(mistakes);
    map['repeated_items'] = Variable<int>(repeatedItems);
    map['fsrs_generated'] = Variable<int>(fsrsGenerated);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  PracticeAttemptsLocalCompanion toCompanion(bool nullToAbsent) {
    return PracticeAttemptsLocalCompanion(
      id: Value(id),
      userId: Value(userId),
      objectiveId: Value(objectiveId),
      scenario: scenario == null && nullToAbsent
          ? const Value.absent()
          : Value(scenario),
      difficultyBand: difficultyBand == null && nullToAbsent
          ? const Value.absent()
          : Value(difficultyBand),
      track: Value(track),
      score: Value(score),
      durationSeconds: Value(durationSeconds),
      mistakes: Value(mistakes),
      repeatedItems: Value(repeatedItems),
      fsrsGenerated: Value(fsrsGenerated),
      createdAt: Value(createdAt),
      isSynced: Value(isSynced),
    );
  }

  factory PracticeAttemptsLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PracticeAttemptsLocalData(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      objectiveId: serializer.fromJson<String>(json['objectiveId']),
      scenario: serializer.fromJson<String?>(json['scenario']),
      difficultyBand: serializer.fromJson<String?>(json['difficultyBand']),
      track: serializer.fromJson<String>(json['track']),
      score: serializer.fromJson<double>(json['score']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      mistakes: serializer.fromJson<int>(json['mistakes']),
      repeatedItems: serializer.fromJson<int>(json['repeatedItems']),
      fsrsGenerated: serializer.fromJson<int>(json['fsrsGenerated']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'objectiveId': serializer.toJson<String>(objectiveId),
      'scenario': serializer.toJson<String?>(scenario),
      'difficultyBand': serializer.toJson<String?>(difficultyBand),
      'track': serializer.toJson<String>(track),
      'score': serializer.toJson<double>(score),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'mistakes': serializer.toJson<int>(mistakes),
      'repeatedItems': serializer.toJson<int>(repeatedItems),
      'fsrsGenerated': serializer.toJson<int>(fsrsGenerated),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  PracticeAttemptsLocalData copyWith({
    int? id,
    String? userId,
    String? objectiveId,
    Value<String?> scenario = const Value.absent(),
    Value<String?> difficultyBand = const Value.absent(),
    String? track,
    double? score,
    int? durationSeconds,
    int? mistakes,
    int? repeatedItems,
    int? fsrsGenerated,
    DateTime? createdAt,
    bool? isSynced,
  }) => PracticeAttemptsLocalData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    objectiveId: objectiveId ?? this.objectiveId,
    scenario: scenario.present ? scenario.value : this.scenario,
    difficultyBand: difficultyBand.present
        ? difficultyBand.value
        : this.difficultyBand,
    track: track ?? this.track,
    score: score ?? this.score,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    mistakes: mistakes ?? this.mistakes,
    repeatedItems: repeatedItems ?? this.repeatedItems,
    fsrsGenerated: fsrsGenerated ?? this.fsrsGenerated,
    createdAt: createdAt ?? this.createdAt,
    isSynced: isSynced ?? this.isSynced,
  );
  PracticeAttemptsLocalData copyWithCompanion(
    PracticeAttemptsLocalCompanion data,
  ) {
    return PracticeAttemptsLocalData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      objectiveId: data.objectiveId.present
          ? data.objectiveId.value
          : this.objectiveId,
      scenario: data.scenario.present ? data.scenario.value : this.scenario,
      difficultyBand: data.difficultyBand.present
          ? data.difficultyBand.value
          : this.difficultyBand,
      track: data.track.present ? data.track.value : this.track,
      score: data.score.present ? data.score.value : this.score,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      mistakes: data.mistakes.present ? data.mistakes.value : this.mistakes,
      repeatedItems: data.repeatedItems.present
          ? data.repeatedItems.value
          : this.repeatedItems,
      fsrsGenerated: data.fsrsGenerated.present
          ? data.fsrsGenerated.value
          : this.fsrsGenerated,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PracticeAttemptsLocalData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('objectiveId: $objectiveId, ')
          ..write('scenario: $scenario, ')
          ..write('difficultyBand: $difficultyBand, ')
          ..write('track: $track, ')
          ..write('score: $score, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('mistakes: $mistakes, ')
          ..write('repeatedItems: $repeatedItems, ')
          ..write('fsrsGenerated: $fsrsGenerated, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    objectiveId,
    scenario,
    difficultyBand,
    track,
    score,
    durationSeconds,
    mistakes,
    repeatedItems,
    fsrsGenerated,
    createdAt,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PracticeAttemptsLocalData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.objectiveId == this.objectiveId &&
          other.scenario == this.scenario &&
          other.difficultyBand == this.difficultyBand &&
          other.track == this.track &&
          other.score == this.score &&
          other.durationSeconds == this.durationSeconds &&
          other.mistakes == this.mistakes &&
          other.repeatedItems == this.repeatedItems &&
          other.fsrsGenerated == this.fsrsGenerated &&
          other.createdAt == this.createdAt &&
          other.isSynced == this.isSynced);
}

class PracticeAttemptsLocalCompanion
    extends UpdateCompanion<PracticeAttemptsLocalData> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> objectiveId;
  final Value<String?> scenario;
  final Value<String?> difficultyBand;
  final Value<String> track;
  final Value<double> score;
  final Value<int> durationSeconds;
  final Value<int> mistakes;
  final Value<int> repeatedItems;
  final Value<int> fsrsGenerated;
  final Value<DateTime> createdAt;
  final Value<bool> isSynced;
  const PracticeAttemptsLocalCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.objectiveId = const Value.absent(),
    this.scenario = const Value.absent(),
    this.difficultyBand = const Value.absent(),
    this.track = const Value.absent(),
    this.score = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.mistakes = const Value.absent(),
    this.repeatedItems = const Value.absent(),
    this.fsrsGenerated = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
  });
  PracticeAttemptsLocalCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required String objectiveId,
    this.scenario = const Value.absent(),
    this.difficultyBand = const Value.absent(),
    required String track,
    this.score = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.mistakes = const Value.absent(),
    this.repeatedItems = const Value.absent(),
    this.fsrsGenerated = const Value.absent(),
    required DateTime createdAt,
    this.isSynced = const Value.absent(),
  }) : userId = Value(userId),
       objectiveId = Value(objectiveId),
       track = Value(track),
       createdAt = Value(createdAt);
  static Insertable<PracticeAttemptsLocalData> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? objectiveId,
    Expression<String>? scenario,
    Expression<String>? difficultyBand,
    Expression<String>? track,
    Expression<double>? score,
    Expression<int>? durationSeconds,
    Expression<int>? mistakes,
    Expression<int>? repeatedItems,
    Expression<int>? fsrsGenerated,
    Expression<DateTime>? createdAt,
    Expression<bool>? isSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (objectiveId != null) 'objective_id': objectiveId,
      if (scenario != null) 'scenario': scenario,
      if (difficultyBand != null) 'difficulty_band': difficultyBand,
      if (track != null) 'track': track,
      if (score != null) 'score': score,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (mistakes != null) 'mistakes': mistakes,
      if (repeatedItems != null) 'repeated_items': repeatedItems,
      if (fsrsGenerated != null) 'fsrs_generated': fsrsGenerated,
      if (createdAt != null) 'created_at': createdAt,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  PracticeAttemptsLocalCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? objectiveId,
    Value<String?>? scenario,
    Value<String?>? difficultyBand,
    Value<String>? track,
    Value<double>? score,
    Value<int>? durationSeconds,
    Value<int>? mistakes,
    Value<int>? repeatedItems,
    Value<int>? fsrsGenerated,
    Value<DateTime>? createdAt,
    Value<bool>? isSynced,
  }) {
    return PracticeAttemptsLocalCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      objectiveId: objectiveId ?? this.objectiveId,
      scenario: scenario ?? this.scenario,
      difficultyBand: difficultyBand ?? this.difficultyBand,
      track: track ?? this.track,
      score: score ?? this.score,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      mistakes: mistakes ?? this.mistakes,
      repeatedItems: repeatedItems ?? this.repeatedItems,
      fsrsGenerated: fsrsGenerated ?? this.fsrsGenerated,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (objectiveId.present) {
      map['objective_id'] = Variable<String>(objectiveId.value);
    }
    if (scenario.present) {
      map['scenario'] = Variable<String>(scenario.value);
    }
    if (difficultyBand.present) {
      map['difficulty_band'] = Variable<String>(difficultyBand.value);
    }
    if (track.present) {
      map['track'] = Variable<String>(track.value);
    }
    if (score.present) {
      map['score'] = Variable<double>(score.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (mistakes.present) {
      map['mistakes'] = Variable<int>(mistakes.value);
    }
    if (repeatedItems.present) {
      map['repeated_items'] = Variable<int>(repeatedItems.value);
    }
    if (fsrsGenerated.present) {
      map['fsrs_generated'] = Variable<int>(fsrsGenerated.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PracticeAttemptsLocalCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('objectiveId: $objectiveId, ')
          ..write('scenario: $scenario, ')
          ..write('difficultyBand: $difficultyBand, ')
          ..write('track: $track, ')
          ..write('score: $score, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('mistakes: $mistakes, ')
          ..write('repeatedItems: $repeatedItems, ')
          ..write('fsrsGenerated: $fsrsGenerated, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }
}

class $UserPhonemeProgressLocalTable extends UserPhonemeProgressLocal
    with
        TableInfo<
          $UserPhonemeProgressLocalTable,
          UserPhonemeProgressLocalData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPhonemeProgressLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phonemeMeta = const VerificationMeta(
    'phoneme',
  );
  @override
  late final GeneratedColumn<String> phoneme = GeneratedColumn<String>(
    'phoneme',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _successesMeta = const VerificationMeta(
    'successes',
  );
  @override
  late final GeneratedColumn<int> successes = GeneratedColumn<int>(
    'successes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _meanGopMeta = const VerificationMeta(
    'meanGop',
  );
  @override
  late final GeneratedColumn<double> meanGop = GeneratedColumn<double>(
    'mean_gop',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _lastGopMeta = const VerificationMeta(
    'lastGop',
  );
  @override
  late final GeneratedColumn<double> lastGop = GeneratedColumn<double>(
    'last_gop',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _recencyWeightedGopMeta =
      const VerificationMeta('recencyWeightedGop');
  @override
  late final GeneratedColumn<double> recencyWeightedGop =
      GeneratedColumn<double>(
        'recency_weighted_gop',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _wilsonLowerBoundMeta = const VerificationMeta(
    'wilsonLowerBound',
  );
  @override
  late final GeneratedColumn<double> wilsonLowerBound = GeneratedColumn<double>(
    'wilson_lower_bound',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _confusionMapJsonMeta = const VerificationMeta(
    'confusionMapJson',
  );
  @override
  late final GeneratedColumn<String> confusionMapJson = GeneratedColumn<String>(
    'confusion_map_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _lastPracticedAtMeta = const VerificationMeta(
    'lastPracticedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPracticedAt =
      GeneratedColumn<DateTime>(
        'last_practiced_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    phoneme,
    attempts,
    successes,
    meanGop,
    lastGop,
    recencyWeightedGop,
    wilsonLowerBound,
    confusionMapJson,
    lastPracticedAt,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_phoneme_progress_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserPhonemeProgressLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('phoneme')) {
      context.handle(
        _phonemeMeta,
        phoneme.isAcceptableOrUnknown(data['phoneme']!, _phonemeMeta),
      );
    } else if (isInserting) {
      context.missing(_phonemeMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('successes')) {
      context.handle(
        _successesMeta,
        successes.isAcceptableOrUnknown(data['successes']!, _successesMeta),
      );
    }
    if (data.containsKey('mean_gop')) {
      context.handle(
        _meanGopMeta,
        meanGop.isAcceptableOrUnknown(data['mean_gop']!, _meanGopMeta),
      );
    }
    if (data.containsKey('last_gop')) {
      context.handle(
        _lastGopMeta,
        lastGop.isAcceptableOrUnknown(data['last_gop']!, _lastGopMeta),
      );
    }
    if (data.containsKey('recency_weighted_gop')) {
      context.handle(
        _recencyWeightedGopMeta,
        recencyWeightedGop.isAcceptableOrUnknown(
          data['recency_weighted_gop']!,
          _recencyWeightedGopMeta,
        ),
      );
    }
    if (data.containsKey('wilson_lower_bound')) {
      context.handle(
        _wilsonLowerBoundMeta,
        wilsonLowerBound.isAcceptableOrUnknown(
          data['wilson_lower_bound']!,
          _wilsonLowerBoundMeta,
        ),
      );
    }
    if (data.containsKey('confusion_map_json')) {
      context.handle(
        _confusionMapJsonMeta,
        confusionMapJson.isAcceptableOrUnknown(
          data['confusion_map_json']!,
          _confusionMapJsonMeta,
        ),
      );
    }
    if (data.containsKey('last_practiced_at')) {
      context.handle(
        _lastPracticedAtMeta,
        lastPracticedAt.isAcceptableOrUnknown(
          data['last_practiced_at']!,
          _lastPracticedAtMeta,
        ),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserPhonemeProgressLocalData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPhonemeProgressLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      phoneme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phoneme'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      successes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}successes'],
      )!,
      meanGop: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}mean_gop'],
      )!,
      lastGop: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}last_gop'],
      )!,
      recencyWeightedGop: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}recency_weighted_gop'],
      )!,
      wilsonLowerBound: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}wilson_lower_bound'],
      )!,
      confusionMapJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}confusion_map_json'],
      )!,
      lastPracticedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_practiced_at'],
      ),
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $UserPhonemeProgressLocalTable createAlias(String alias) {
    return $UserPhonemeProgressLocalTable(attachedDatabase, alias);
  }
}

class UserPhonemeProgressLocalData extends DataClass
    implements Insertable<UserPhonemeProgressLocalData> {
  final int id;
  final String userId;
  final String phoneme;
  final int attempts;
  final int successes;
  final double meanGop;
  final double lastGop;
  final double recencyWeightedGop;
  final double wilsonLowerBound;
  final String confusionMapJson;
  final DateTime? lastPracticedAt;
  final bool isSynced;
  const UserPhonemeProgressLocalData({
    required this.id,
    required this.userId,
    required this.phoneme,
    required this.attempts,
    required this.successes,
    required this.meanGop,
    required this.lastGop,
    required this.recencyWeightedGop,
    required this.wilsonLowerBound,
    required this.confusionMapJson,
    this.lastPracticedAt,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['phoneme'] = Variable<String>(phoneme);
    map['attempts'] = Variable<int>(attempts);
    map['successes'] = Variable<int>(successes);
    map['mean_gop'] = Variable<double>(meanGop);
    map['last_gop'] = Variable<double>(lastGop);
    map['recency_weighted_gop'] = Variable<double>(recencyWeightedGop);
    map['wilson_lower_bound'] = Variable<double>(wilsonLowerBound);
    map['confusion_map_json'] = Variable<String>(confusionMapJson);
    if (!nullToAbsent || lastPracticedAt != null) {
      map['last_practiced_at'] = Variable<DateTime>(lastPracticedAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  UserPhonemeProgressLocalCompanion toCompanion(bool nullToAbsent) {
    return UserPhonemeProgressLocalCompanion(
      id: Value(id),
      userId: Value(userId),
      phoneme: Value(phoneme),
      attempts: Value(attempts),
      successes: Value(successes),
      meanGop: Value(meanGop),
      lastGop: Value(lastGop),
      recencyWeightedGop: Value(recencyWeightedGop),
      wilsonLowerBound: Value(wilsonLowerBound),
      confusionMapJson: Value(confusionMapJson),
      lastPracticedAt: lastPracticedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPracticedAt),
      isSynced: Value(isSynced),
    );
  }

  factory UserPhonemeProgressLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPhonemeProgressLocalData(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      phoneme: serializer.fromJson<String>(json['phoneme']),
      attempts: serializer.fromJson<int>(json['attempts']),
      successes: serializer.fromJson<int>(json['successes']),
      meanGop: serializer.fromJson<double>(json['meanGop']),
      lastGop: serializer.fromJson<double>(json['lastGop']),
      recencyWeightedGop: serializer.fromJson<double>(
        json['recencyWeightedGop'],
      ),
      wilsonLowerBound: serializer.fromJson<double>(json['wilsonLowerBound']),
      confusionMapJson: serializer.fromJson<String>(json['confusionMapJson']),
      lastPracticedAt: serializer.fromJson<DateTime?>(json['lastPracticedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'phoneme': serializer.toJson<String>(phoneme),
      'attempts': serializer.toJson<int>(attempts),
      'successes': serializer.toJson<int>(successes),
      'meanGop': serializer.toJson<double>(meanGop),
      'lastGop': serializer.toJson<double>(lastGop),
      'recencyWeightedGop': serializer.toJson<double>(recencyWeightedGop),
      'wilsonLowerBound': serializer.toJson<double>(wilsonLowerBound),
      'confusionMapJson': serializer.toJson<String>(confusionMapJson),
      'lastPracticedAt': serializer.toJson<DateTime?>(lastPracticedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  UserPhonemeProgressLocalData copyWith({
    int? id,
    String? userId,
    String? phoneme,
    int? attempts,
    int? successes,
    double? meanGop,
    double? lastGop,
    double? recencyWeightedGop,
    double? wilsonLowerBound,
    String? confusionMapJson,
    Value<DateTime?> lastPracticedAt = const Value.absent(),
    bool? isSynced,
  }) => UserPhonemeProgressLocalData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    phoneme: phoneme ?? this.phoneme,
    attempts: attempts ?? this.attempts,
    successes: successes ?? this.successes,
    meanGop: meanGop ?? this.meanGop,
    lastGop: lastGop ?? this.lastGop,
    recencyWeightedGop: recencyWeightedGop ?? this.recencyWeightedGop,
    wilsonLowerBound: wilsonLowerBound ?? this.wilsonLowerBound,
    confusionMapJson: confusionMapJson ?? this.confusionMapJson,
    lastPracticedAt: lastPracticedAt.present
        ? lastPracticedAt.value
        : this.lastPracticedAt,
    isSynced: isSynced ?? this.isSynced,
  );
  UserPhonemeProgressLocalData copyWithCompanion(
    UserPhonemeProgressLocalCompanion data,
  ) {
    return UserPhonemeProgressLocalData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      phoneme: data.phoneme.present ? data.phoneme.value : this.phoneme,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      successes: data.successes.present ? data.successes.value : this.successes,
      meanGop: data.meanGop.present ? data.meanGop.value : this.meanGop,
      lastGop: data.lastGop.present ? data.lastGop.value : this.lastGop,
      recencyWeightedGop: data.recencyWeightedGop.present
          ? data.recencyWeightedGop.value
          : this.recencyWeightedGop,
      wilsonLowerBound: data.wilsonLowerBound.present
          ? data.wilsonLowerBound.value
          : this.wilsonLowerBound,
      confusionMapJson: data.confusionMapJson.present
          ? data.confusionMapJson.value
          : this.confusionMapJson,
      lastPracticedAt: data.lastPracticedAt.present
          ? data.lastPracticedAt.value
          : this.lastPracticedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPhonemeProgressLocalData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('phoneme: $phoneme, ')
          ..write('attempts: $attempts, ')
          ..write('successes: $successes, ')
          ..write('meanGop: $meanGop, ')
          ..write('lastGop: $lastGop, ')
          ..write('recencyWeightedGop: $recencyWeightedGop, ')
          ..write('wilsonLowerBound: $wilsonLowerBound, ')
          ..write('confusionMapJson: $confusionMapJson, ')
          ..write('lastPracticedAt: $lastPracticedAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    phoneme,
    attempts,
    successes,
    meanGop,
    lastGop,
    recencyWeightedGop,
    wilsonLowerBound,
    confusionMapJson,
    lastPracticedAt,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPhonemeProgressLocalData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.phoneme == this.phoneme &&
          other.attempts == this.attempts &&
          other.successes == this.successes &&
          other.meanGop == this.meanGop &&
          other.lastGop == this.lastGop &&
          other.recencyWeightedGop == this.recencyWeightedGop &&
          other.wilsonLowerBound == this.wilsonLowerBound &&
          other.confusionMapJson == this.confusionMapJson &&
          other.lastPracticedAt == this.lastPracticedAt &&
          other.isSynced == this.isSynced);
}

class UserPhonemeProgressLocalCompanion
    extends UpdateCompanion<UserPhonemeProgressLocalData> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> phoneme;
  final Value<int> attempts;
  final Value<int> successes;
  final Value<double> meanGop;
  final Value<double> lastGop;
  final Value<double> recencyWeightedGop;
  final Value<double> wilsonLowerBound;
  final Value<String> confusionMapJson;
  final Value<DateTime?> lastPracticedAt;
  final Value<bool> isSynced;
  const UserPhonemeProgressLocalCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.phoneme = const Value.absent(),
    this.attempts = const Value.absent(),
    this.successes = const Value.absent(),
    this.meanGop = const Value.absent(),
    this.lastGop = const Value.absent(),
    this.recencyWeightedGop = const Value.absent(),
    this.wilsonLowerBound = const Value.absent(),
    this.confusionMapJson = const Value.absent(),
    this.lastPracticedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
  });
  UserPhonemeProgressLocalCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required String phoneme,
    this.attempts = const Value.absent(),
    this.successes = const Value.absent(),
    this.meanGop = const Value.absent(),
    this.lastGop = const Value.absent(),
    this.recencyWeightedGop = const Value.absent(),
    this.wilsonLowerBound = const Value.absent(),
    this.confusionMapJson = const Value.absent(),
    this.lastPracticedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
  }) : userId = Value(userId),
       phoneme = Value(phoneme);
  static Insertable<UserPhonemeProgressLocalData> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? phoneme,
    Expression<int>? attempts,
    Expression<int>? successes,
    Expression<double>? meanGop,
    Expression<double>? lastGop,
    Expression<double>? recencyWeightedGop,
    Expression<double>? wilsonLowerBound,
    Expression<String>? confusionMapJson,
    Expression<DateTime>? lastPracticedAt,
    Expression<bool>? isSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (phoneme != null) 'phoneme': phoneme,
      if (attempts != null) 'attempts': attempts,
      if (successes != null) 'successes': successes,
      if (meanGop != null) 'mean_gop': meanGop,
      if (lastGop != null) 'last_gop': lastGop,
      if (recencyWeightedGop != null)
        'recency_weighted_gop': recencyWeightedGop,
      if (wilsonLowerBound != null) 'wilson_lower_bound': wilsonLowerBound,
      if (confusionMapJson != null) 'confusion_map_json': confusionMapJson,
      if (lastPracticedAt != null) 'last_practiced_at': lastPracticedAt,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  UserPhonemeProgressLocalCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? phoneme,
    Value<int>? attempts,
    Value<int>? successes,
    Value<double>? meanGop,
    Value<double>? lastGop,
    Value<double>? recencyWeightedGop,
    Value<double>? wilsonLowerBound,
    Value<String>? confusionMapJson,
    Value<DateTime?>? lastPracticedAt,
    Value<bool>? isSynced,
  }) {
    return UserPhonemeProgressLocalCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      phoneme: phoneme ?? this.phoneme,
      attempts: attempts ?? this.attempts,
      successes: successes ?? this.successes,
      meanGop: meanGop ?? this.meanGop,
      lastGop: lastGop ?? this.lastGop,
      recencyWeightedGop: recencyWeightedGop ?? this.recencyWeightedGop,
      wilsonLowerBound: wilsonLowerBound ?? this.wilsonLowerBound,
      confusionMapJson: confusionMapJson ?? this.confusionMapJson,
      lastPracticedAt: lastPracticedAt ?? this.lastPracticedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (phoneme.present) {
      map['phoneme'] = Variable<String>(phoneme.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (successes.present) {
      map['successes'] = Variable<int>(successes.value);
    }
    if (meanGop.present) {
      map['mean_gop'] = Variable<double>(meanGop.value);
    }
    if (lastGop.present) {
      map['last_gop'] = Variable<double>(lastGop.value);
    }
    if (recencyWeightedGop.present) {
      map['recency_weighted_gop'] = Variable<double>(recencyWeightedGop.value);
    }
    if (wilsonLowerBound.present) {
      map['wilson_lower_bound'] = Variable<double>(wilsonLowerBound.value);
    }
    if (confusionMapJson.present) {
      map['confusion_map_json'] = Variable<String>(confusionMapJson.value);
    }
    if (lastPracticedAt.present) {
      map['last_practiced_at'] = Variable<DateTime>(lastPracticedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPhonemeProgressLocalCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('phoneme: $phoneme, ')
          ..write('attempts: $attempts, ')
          ..write('successes: $successes, ')
          ..write('meanGop: $meanGop, ')
          ..write('lastGop: $lastGop, ')
          ..write('recencyWeightedGop: $recencyWeightedGop, ')
          ..write('wilsonLowerBound: $wilsonLowerBound, ')
          ..write('confusionMapJson: $confusionMapJson, ')
          ..write('lastPracticedAt: $lastPracticedAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }
}

class $UserAudioBaselinesLocalTable extends UserAudioBaselinesLocal
    with TableInfo<$UserAudioBaselinesLocalTable, UserAudioBaselinesLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserAudioBaselinesLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetTypeMeta = const VerificationMeta(
    'targetType',
  );
  @override
  late final GeneratedColumn<String> targetType = GeneratedColumn<String>(
    'target_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetIdMeta = const VerificationMeta(
    'targetId',
  );
  @override
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
    'target_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baselineAudioPathMeta = const VerificationMeta(
    'baselineAudioPath',
  );
  @override
  late final GeneratedColumn<String> baselineAudioPath =
      GeneratedColumn<String>(
        'baseline_audio_path',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _baselineScoreMeta = const VerificationMeta(
    'baselineScore',
  );
  @override
  late final GeneratedColumn<double> baselineScore = GeneratedColumn<double>(
    'baseline_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _baselineGopMeta = const VerificationMeta(
    'baselineGop',
  );
  @override
  late final GeneratedColumn<double> baselineGop = GeneratedColumn<double>(
    'baseline_gop',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _baselineCreatedAtMeta = const VerificationMeta(
    'baselineCreatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> baselineCreatedAt =
      GeneratedColumn<DateTime>(
        'baseline_created_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _latestAudioPathMeta = const VerificationMeta(
    'latestAudioPath',
  );
  @override
  late final GeneratedColumn<String> latestAudioPath = GeneratedColumn<String>(
    'latest_audio_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latestScoreMeta = const VerificationMeta(
    'latestScore',
  );
  @override
  late final GeneratedColumn<double> latestScore = GeneratedColumn<double>(
    'latest_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latestGopMeta = const VerificationMeta(
    'latestGop',
  );
  @override
  late final GeneratedColumn<double> latestGop = GeneratedColumn<double>(
    'latest_gop',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latestUpdatedAtMeta = const VerificationMeta(
    'latestUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> latestUpdatedAt =
      GeneratedColumn<DateTime>(
        'latest_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    targetType,
    targetId,
    baselineAudioPath,
    baselineScore,
    baselineGop,
    baselineCreatedAt,
    latestAudioPath,
    latestScore,
    latestGop,
    latestUpdatedAt,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_audio_baselines_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserAudioBaselinesLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('target_type')) {
      context.handle(
        _targetTypeMeta,
        targetType.isAcceptableOrUnknown(data['target_type']!, _targetTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_targetTypeMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(
        _targetIdMeta,
        targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_targetIdMeta);
    }
    if (data.containsKey('baseline_audio_path')) {
      context.handle(
        _baselineAudioPathMeta,
        baselineAudioPath.isAcceptableOrUnknown(
          data['baseline_audio_path']!,
          _baselineAudioPathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baselineAudioPathMeta);
    }
    if (data.containsKey('baseline_score')) {
      context.handle(
        _baselineScoreMeta,
        baselineScore.isAcceptableOrUnknown(
          data['baseline_score']!,
          _baselineScoreMeta,
        ),
      );
    }
    if (data.containsKey('baseline_gop')) {
      context.handle(
        _baselineGopMeta,
        baselineGop.isAcceptableOrUnknown(
          data['baseline_gop']!,
          _baselineGopMeta,
        ),
      );
    }
    if (data.containsKey('baseline_created_at')) {
      context.handle(
        _baselineCreatedAtMeta,
        baselineCreatedAt.isAcceptableOrUnknown(
          data['baseline_created_at']!,
          _baselineCreatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baselineCreatedAtMeta);
    }
    if (data.containsKey('latest_audio_path')) {
      context.handle(
        _latestAudioPathMeta,
        latestAudioPath.isAcceptableOrUnknown(
          data['latest_audio_path']!,
          _latestAudioPathMeta,
        ),
      );
    }
    if (data.containsKey('latest_score')) {
      context.handle(
        _latestScoreMeta,
        latestScore.isAcceptableOrUnknown(
          data['latest_score']!,
          _latestScoreMeta,
        ),
      );
    }
    if (data.containsKey('latest_gop')) {
      context.handle(
        _latestGopMeta,
        latestGop.isAcceptableOrUnknown(data['latest_gop']!, _latestGopMeta),
      );
    }
    if (data.containsKey('latest_updated_at')) {
      context.handle(
        _latestUpdatedAtMeta,
        latestUpdatedAt.isAcceptableOrUnknown(
          data['latest_updated_at']!,
          _latestUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserAudioBaselinesLocalData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserAudioBaselinesLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      targetType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_type'],
      )!,
      targetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_id'],
      )!,
      baselineAudioPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}baseline_audio_path'],
      )!,
      baselineScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}baseline_score'],
      )!,
      baselineGop: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}baseline_gop'],
      )!,
      baselineCreatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}baseline_created_at'],
      )!,
      latestAudioPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}latest_audio_path'],
      ),
      latestScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latest_score'],
      ),
      latestGop: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latest_gop'],
      ),
      latestUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}latest_updated_at'],
      ),
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $UserAudioBaselinesLocalTable createAlias(String alias) {
    return $UserAudioBaselinesLocalTable(attachedDatabase, alias);
  }
}

class UserAudioBaselinesLocalData extends DataClass
    implements Insertable<UserAudioBaselinesLocalData> {
  final String id;
  final String userId;
  final String targetType;
  final String targetId;
  final String baselineAudioPath;
  final double baselineScore;
  final double baselineGop;
  final DateTime baselineCreatedAt;
  final String? latestAudioPath;
  final double? latestScore;
  final double? latestGop;
  final DateTime? latestUpdatedAt;
  final bool isSynced;
  const UserAudioBaselinesLocalData({
    required this.id,
    required this.userId,
    required this.targetType,
    required this.targetId,
    required this.baselineAudioPath,
    required this.baselineScore,
    required this.baselineGop,
    required this.baselineCreatedAt,
    this.latestAudioPath,
    this.latestScore,
    this.latestGop,
    this.latestUpdatedAt,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['target_type'] = Variable<String>(targetType);
    map['target_id'] = Variable<String>(targetId);
    map['baseline_audio_path'] = Variable<String>(baselineAudioPath);
    map['baseline_score'] = Variable<double>(baselineScore);
    map['baseline_gop'] = Variable<double>(baselineGop);
    map['baseline_created_at'] = Variable<DateTime>(baselineCreatedAt);
    if (!nullToAbsent || latestAudioPath != null) {
      map['latest_audio_path'] = Variable<String>(latestAudioPath);
    }
    if (!nullToAbsent || latestScore != null) {
      map['latest_score'] = Variable<double>(latestScore);
    }
    if (!nullToAbsent || latestGop != null) {
      map['latest_gop'] = Variable<double>(latestGop);
    }
    if (!nullToAbsent || latestUpdatedAt != null) {
      map['latest_updated_at'] = Variable<DateTime>(latestUpdatedAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  UserAudioBaselinesLocalCompanion toCompanion(bool nullToAbsent) {
    return UserAudioBaselinesLocalCompanion(
      id: Value(id),
      userId: Value(userId),
      targetType: Value(targetType),
      targetId: Value(targetId),
      baselineAudioPath: Value(baselineAudioPath),
      baselineScore: Value(baselineScore),
      baselineGop: Value(baselineGop),
      baselineCreatedAt: Value(baselineCreatedAt),
      latestAudioPath: latestAudioPath == null && nullToAbsent
          ? const Value.absent()
          : Value(latestAudioPath),
      latestScore: latestScore == null && nullToAbsent
          ? const Value.absent()
          : Value(latestScore),
      latestGop: latestGop == null && nullToAbsent
          ? const Value.absent()
          : Value(latestGop),
      latestUpdatedAt: latestUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(latestUpdatedAt),
      isSynced: Value(isSynced),
    );
  }

  factory UserAudioBaselinesLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserAudioBaselinesLocalData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      targetType: serializer.fromJson<String>(json['targetType']),
      targetId: serializer.fromJson<String>(json['targetId']),
      baselineAudioPath: serializer.fromJson<String>(json['baselineAudioPath']),
      baselineScore: serializer.fromJson<double>(json['baselineScore']),
      baselineGop: serializer.fromJson<double>(json['baselineGop']),
      baselineCreatedAt: serializer.fromJson<DateTime>(
        json['baselineCreatedAt'],
      ),
      latestAudioPath: serializer.fromJson<String?>(json['latestAudioPath']),
      latestScore: serializer.fromJson<double?>(json['latestScore']),
      latestGop: serializer.fromJson<double?>(json['latestGop']),
      latestUpdatedAt: serializer.fromJson<DateTime?>(json['latestUpdatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'targetType': serializer.toJson<String>(targetType),
      'targetId': serializer.toJson<String>(targetId),
      'baselineAudioPath': serializer.toJson<String>(baselineAudioPath),
      'baselineScore': serializer.toJson<double>(baselineScore),
      'baselineGop': serializer.toJson<double>(baselineGop),
      'baselineCreatedAt': serializer.toJson<DateTime>(baselineCreatedAt),
      'latestAudioPath': serializer.toJson<String?>(latestAudioPath),
      'latestScore': serializer.toJson<double?>(latestScore),
      'latestGop': serializer.toJson<double?>(latestGop),
      'latestUpdatedAt': serializer.toJson<DateTime?>(latestUpdatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  UserAudioBaselinesLocalData copyWith({
    String? id,
    String? userId,
    String? targetType,
    String? targetId,
    String? baselineAudioPath,
    double? baselineScore,
    double? baselineGop,
    DateTime? baselineCreatedAt,
    Value<String?> latestAudioPath = const Value.absent(),
    Value<double?> latestScore = const Value.absent(),
    Value<double?> latestGop = const Value.absent(),
    Value<DateTime?> latestUpdatedAt = const Value.absent(),
    bool? isSynced,
  }) => UserAudioBaselinesLocalData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    targetType: targetType ?? this.targetType,
    targetId: targetId ?? this.targetId,
    baselineAudioPath: baselineAudioPath ?? this.baselineAudioPath,
    baselineScore: baselineScore ?? this.baselineScore,
    baselineGop: baselineGop ?? this.baselineGop,
    baselineCreatedAt: baselineCreatedAt ?? this.baselineCreatedAt,
    latestAudioPath: latestAudioPath.present
        ? latestAudioPath.value
        : this.latestAudioPath,
    latestScore: latestScore.present ? latestScore.value : this.latestScore,
    latestGop: latestGop.present ? latestGop.value : this.latestGop,
    latestUpdatedAt: latestUpdatedAt.present
        ? latestUpdatedAt.value
        : this.latestUpdatedAt,
    isSynced: isSynced ?? this.isSynced,
  );
  UserAudioBaselinesLocalData copyWithCompanion(
    UserAudioBaselinesLocalCompanion data,
  ) {
    return UserAudioBaselinesLocalData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      targetType: data.targetType.present
          ? data.targetType.value
          : this.targetType,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      baselineAudioPath: data.baselineAudioPath.present
          ? data.baselineAudioPath.value
          : this.baselineAudioPath,
      baselineScore: data.baselineScore.present
          ? data.baselineScore.value
          : this.baselineScore,
      baselineGop: data.baselineGop.present
          ? data.baselineGop.value
          : this.baselineGop,
      baselineCreatedAt: data.baselineCreatedAt.present
          ? data.baselineCreatedAt.value
          : this.baselineCreatedAt,
      latestAudioPath: data.latestAudioPath.present
          ? data.latestAudioPath.value
          : this.latestAudioPath,
      latestScore: data.latestScore.present
          ? data.latestScore.value
          : this.latestScore,
      latestGop: data.latestGop.present ? data.latestGop.value : this.latestGop,
      latestUpdatedAt: data.latestUpdatedAt.present
          ? data.latestUpdatedAt.value
          : this.latestUpdatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserAudioBaselinesLocalData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId, ')
          ..write('baselineAudioPath: $baselineAudioPath, ')
          ..write('baselineScore: $baselineScore, ')
          ..write('baselineGop: $baselineGop, ')
          ..write('baselineCreatedAt: $baselineCreatedAt, ')
          ..write('latestAudioPath: $latestAudioPath, ')
          ..write('latestScore: $latestScore, ')
          ..write('latestGop: $latestGop, ')
          ..write('latestUpdatedAt: $latestUpdatedAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    targetType,
    targetId,
    baselineAudioPath,
    baselineScore,
    baselineGop,
    baselineCreatedAt,
    latestAudioPath,
    latestScore,
    latestGop,
    latestUpdatedAt,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserAudioBaselinesLocalData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.targetType == this.targetType &&
          other.targetId == this.targetId &&
          other.baselineAudioPath == this.baselineAudioPath &&
          other.baselineScore == this.baselineScore &&
          other.baselineGop == this.baselineGop &&
          other.baselineCreatedAt == this.baselineCreatedAt &&
          other.latestAudioPath == this.latestAudioPath &&
          other.latestScore == this.latestScore &&
          other.latestGop == this.latestGop &&
          other.latestUpdatedAt == this.latestUpdatedAt &&
          other.isSynced == this.isSynced);
}

class UserAudioBaselinesLocalCompanion
    extends UpdateCompanion<UserAudioBaselinesLocalData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> targetType;
  final Value<String> targetId;
  final Value<String> baselineAudioPath;
  final Value<double> baselineScore;
  final Value<double> baselineGop;
  final Value<DateTime> baselineCreatedAt;
  final Value<String?> latestAudioPath;
  final Value<double?> latestScore;
  final Value<double?> latestGop;
  final Value<DateTime?> latestUpdatedAt;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const UserAudioBaselinesLocalCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.targetType = const Value.absent(),
    this.targetId = const Value.absent(),
    this.baselineAudioPath = const Value.absent(),
    this.baselineScore = const Value.absent(),
    this.baselineGop = const Value.absent(),
    this.baselineCreatedAt = const Value.absent(),
    this.latestAudioPath = const Value.absent(),
    this.latestScore = const Value.absent(),
    this.latestGop = const Value.absent(),
    this.latestUpdatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserAudioBaselinesLocalCompanion.insert({
    required String id,
    required String userId,
    required String targetType,
    required String targetId,
    required String baselineAudioPath,
    this.baselineScore = const Value.absent(),
    this.baselineGop = const Value.absent(),
    required DateTime baselineCreatedAt,
    this.latestAudioPath = const Value.absent(),
    this.latestScore = const Value.absent(),
    this.latestGop = const Value.absent(),
    this.latestUpdatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       targetType = Value(targetType),
       targetId = Value(targetId),
       baselineAudioPath = Value(baselineAudioPath),
       baselineCreatedAt = Value(baselineCreatedAt);
  static Insertable<UserAudioBaselinesLocalData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? targetType,
    Expression<String>? targetId,
    Expression<String>? baselineAudioPath,
    Expression<double>? baselineScore,
    Expression<double>? baselineGop,
    Expression<DateTime>? baselineCreatedAt,
    Expression<String>? latestAudioPath,
    Expression<double>? latestScore,
    Expression<double>? latestGop,
    Expression<DateTime>? latestUpdatedAt,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (targetType != null) 'target_type': targetType,
      if (targetId != null) 'target_id': targetId,
      if (baselineAudioPath != null) 'baseline_audio_path': baselineAudioPath,
      if (baselineScore != null) 'baseline_score': baselineScore,
      if (baselineGop != null) 'baseline_gop': baselineGop,
      if (baselineCreatedAt != null) 'baseline_created_at': baselineCreatedAt,
      if (latestAudioPath != null) 'latest_audio_path': latestAudioPath,
      if (latestScore != null) 'latest_score': latestScore,
      if (latestGop != null) 'latest_gop': latestGop,
      if (latestUpdatedAt != null) 'latest_updated_at': latestUpdatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserAudioBaselinesLocalCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? targetType,
    Value<String>? targetId,
    Value<String>? baselineAudioPath,
    Value<double>? baselineScore,
    Value<double>? baselineGop,
    Value<DateTime>? baselineCreatedAt,
    Value<String?>? latestAudioPath,
    Value<double?>? latestScore,
    Value<double?>? latestGop,
    Value<DateTime?>? latestUpdatedAt,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return UserAudioBaselinesLocalCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      baselineAudioPath: baselineAudioPath ?? this.baselineAudioPath,
      baselineScore: baselineScore ?? this.baselineScore,
      baselineGop: baselineGop ?? this.baselineGop,
      baselineCreatedAt: baselineCreatedAt ?? this.baselineCreatedAt,
      latestAudioPath: latestAudioPath ?? this.latestAudioPath,
      latestScore: latestScore ?? this.latestScore,
      latestGop: latestGop ?? this.latestGop,
      latestUpdatedAt: latestUpdatedAt ?? this.latestUpdatedAt,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (targetType.present) {
      map['target_type'] = Variable<String>(targetType.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (baselineAudioPath.present) {
      map['baseline_audio_path'] = Variable<String>(baselineAudioPath.value);
    }
    if (baselineScore.present) {
      map['baseline_score'] = Variable<double>(baselineScore.value);
    }
    if (baselineGop.present) {
      map['baseline_gop'] = Variable<double>(baselineGop.value);
    }
    if (baselineCreatedAt.present) {
      map['baseline_created_at'] = Variable<DateTime>(baselineCreatedAt.value);
    }
    if (latestAudioPath.present) {
      map['latest_audio_path'] = Variable<String>(latestAudioPath.value);
    }
    if (latestScore.present) {
      map['latest_score'] = Variable<double>(latestScore.value);
    }
    if (latestGop.present) {
      map['latest_gop'] = Variable<double>(latestGop.value);
    }
    if (latestUpdatedAt.present) {
      map['latest_updated_at'] = Variable<DateTime>(latestUpdatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserAudioBaselinesLocalCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId, ')
          ..write('baselineAudioPath: $baselineAudioPath, ')
          ..write('baselineScore: $baselineScore, ')
          ..write('baselineGop: $baselineGop, ')
          ..write('baselineCreatedAt: $baselineCreatedAt, ')
          ..write('latestAudioPath: $latestAudioPath, ')
          ..write('latestScore: $latestScore, ')
          ..write('latestGop: $latestGop, ')
          ..write('latestUpdatedAt: $latestUpdatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SessionsLocalTable sessionsLocal = $SessionsLocalTable(this);
  late final $TurnsLocalTable turnsLocal = $TurnsLocalTable(this);
  late final $ReviewLogsLocalTable reviewLogsLocal = $ReviewLogsLocalTable(
    this,
  );
  late final $CardsLocalTable cardsLocal = $CardsLocalTable(this);
  late final $QueueItemsTable queueItems = $QueueItemsTable(this);
  late final $JournalEntriesTable journalEntries = $JournalEntriesTable(this);
  late final $UserMilestonesLocalTable userMilestonesLocal =
      $UserMilestonesLocalTable(this);
  late final $ResourcesLocalTable resourcesLocal = $ResourcesLocalTable(this);
  late final $ResourceCollectionsLocalTable resourceCollectionsLocal =
      $ResourceCollectionsLocalTable(this);
  late final $UnitResourceLinksLocalTable unitResourceLinksLocal =
      $UnitResourceLinksLocalTable(this);
  late final $ResourceUsageLogsLocalTable resourceUsageLogsLocal =
      $ResourceUsageLogsLocalTable(this);
  late final $UserProfilesLocalTable userProfilesLocal =
      $UserProfilesLocalTable(this);
  late final $UserAchievementsLocalTable userAchievementsLocal =
      $UserAchievementsLocalTable(this);
  late final $UserActivityDailyLocalTable userActivityDailyLocal =
      $UserActivityDailyLocalTable(this);
  late final $UserSettingsLocalTable userSettingsLocal =
      $UserSettingsLocalTable(this);
  late final $VocabularyProgressLocalTable vocabularyProgressLocal =
      $VocabularyProgressLocalTable(this);
  late final $GrammarProgressLocalTable grammarProgressLocal =
      $GrammarProgressLocalTable(this);
  late final $OfflineEventsLocalTable offlineEventsLocal =
      $OfflineEventsLocalTable(this);
  late final $UnitProgressLocalTable unitProgressLocal =
      $UnitProgressLocalTable(this);
  late final $PracticeAttemptsLocalTable practiceAttemptsLocal =
      $PracticeAttemptsLocalTable(this);
  late final $UserPhonemeProgressLocalTable userPhonemeProgressLocal =
      $UserPhonemeProgressLocalTable(this);
  late final $UserAudioBaselinesLocalTable userAudioBaselinesLocal =
      $UserAudioBaselinesLocalTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sessionsLocal,
    turnsLocal,
    reviewLogsLocal,
    cardsLocal,
    queueItems,
    journalEntries,
    userMilestonesLocal,
    resourcesLocal,
    resourceCollectionsLocal,
    unitResourceLinksLocal,
    resourceUsageLogsLocal,
    userProfilesLocal,
    userAchievementsLocal,
    userActivityDailyLocal,
    userSettingsLocal,
    vocabularyProgressLocal,
    grammarProgressLocal,
    offlineEventsLocal,
    unitProgressLocal,
    practiceAttemptsLocal,
    userPhonemeProgressLocal,
    userAudioBaselinesLocal,
  ];
}

typedef $$SessionsLocalTableCreateCompanionBuilder =
    SessionsLocalCompanion Function({
      required String id,
      required String mode,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<double?> overallScore,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$SessionsLocalTableUpdateCompanionBuilder =
    SessionsLocalCompanion Function({
      Value<String> id,
      Value<String> mode,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<double?> overallScore,
      Value<bool> isSynced,
      Value<int> rowid,
    });

class $$SessionsLocalTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsLocalTable> {
  $$SessionsLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get overallScore => $composableBuilder(
    column: $table.overallScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionsLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsLocalTable> {
  $$SessionsLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get overallScore => $composableBuilder(
    column: $table.overallScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsLocalTable> {
  $$SessionsLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<double> get overallScore => $composableBuilder(
    column: $table.overallScore,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$SessionsLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsLocalTable,
          SessionsLocalData,
          $$SessionsLocalTableFilterComposer,
          $$SessionsLocalTableOrderingComposer,
          $$SessionsLocalTableAnnotationComposer,
          $$SessionsLocalTableCreateCompanionBuilder,
          $$SessionsLocalTableUpdateCompanionBuilder,
          (
            SessionsLocalData,
            BaseReferences<
              _$AppDatabase,
              $SessionsLocalTable,
              SessionsLocalData
            >,
          ),
          SessionsLocalData,
          PrefetchHooks Function()
        > {
  $$SessionsLocalTableTableManager(_$AppDatabase db, $SessionsLocalTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsLocalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<double?> overallScore = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsLocalCompanion(
                id: id,
                mode: mode,
                startedAt: startedAt,
                endedAt: endedAt,
                overallScore: overallScore,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String mode,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<double?> overallScore = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsLocalCompanion.insert(
                id: id,
                mode: mode,
                startedAt: startedAt,
                endedAt: endedAt,
                overallScore: overallScore,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionsLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsLocalTable,
      SessionsLocalData,
      $$SessionsLocalTableFilterComposer,
      $$SessionsLocalTableOrderingComposer,
      $$SessionsLocalTableAnnotationComposer,
      $$SessionsLocalTableCreateCompanionBuilder,
      $$SessionsLocalTableUpdateCompanionBuilder,
      (
        SessionsLocalData,
        BaseReferences<_$AppDatabase, $SessionsLocalTable, SessionsLocalData>,
      ),
      SessionsLocalData,
      PrefetchHooks Function()
    >;
typedef $$TurnsLocalTableCreateCompanionBuilder =
    TurnsLocalCompanion Function({
      Value<int> id,
      required String sessionId,
      Value<int?> questionId,
      required String questionText,
      required String transcript,
      Value<String?> audioPath,
      Value<String?> feedbackJson,
      Value<double?> score,
      required DateTime createdAt,
    });
typedef $$TurnsLocalTableUpdateCompanionBuilder =
    TurnsLocalCompanion Function({
      Value<int> id,
      Value<String> sessionId,
      Value<int?> questionId,
      Value<String> questionText,
      Value<String> transcript,
      Value<String?> audioPath,
      Value<String?> feedbackJson,
      Value<double?> score,
      Value<DateTime> createdAt,
    });

class $$TurnsLocalTableFilterComposer
    extends Composer<_$AppDatabase, $TurnsLocalTable> {
  $$TurnsLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionText => $composableBuilder(
    column: $table.questionText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedbackJson => $composableBuilder(
    column: $table.feedbackJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TurnsLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $TurnsLocalTable> {
  $$TurnsLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionText => $composableBuilder(
    column: $table.questionText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedbackJson => $composableBuilder(
    column: $table.feedbackJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TurnsLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $TurnsLocalTable> {
  $$TurnsLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<int> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get questionText => $composableBuilder(
    column: $table.questionText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => column,
  );

  GeneratedColumn<String> get audioPath =>
      $composableBuilder(column: $table.audioPath, builder: (column) => column);

  GeneratedColumn<String> get feedbackJson => $composableBuilder(
    column: $table.feedbackJson,
    builder: (column) => column,
  );

  GeneratedColumn<double> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TurnsLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TurnsLocalTable,
          TurnsLocalData,
          $$TurnsLocalTableFilterComposer,
          $$TurnsLocalTableOrderingComposer,
          $$TurnsLocalTableAnnotationComposer,
          $$TurnsLocalTableCreateCompanionBuilder,
          $$TurnsLocalTableUpdateCompanionBuilder,
          (
            TurnsLocalData,
            BaseReferences<_$AppDatabase, $TurnsLocalTable, TurnsLocalData>,
          ),
          TurnsLocalData,
          PrefetchHooks Function()
        > {
  $$TurnsLocalTableTableManager(_$AppDatabase db, $TurnsLocalTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TurnsLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TurnsLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TurnsLocalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<int?> questionId = const Value.absent(),
                Value<String> questionText = const Value.absent(),
                Value<String> transcript = const Value.absent(),
                Value<String?> audioPath = const Value.absent(),
                Value<String?> feedbackJson = const Value.absent(),
                Value<double?> score = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TurnsLocalCompanion(
                id: id,
                sessionId: sessionId,
                questionId: questionId,
                questionText: questionText,
                transcript: transcript,
                audioPath: audioPath,
                feedbackJson: feedbackJson,
                score: score,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sessionId,
                Value<int?> questionId = const Value.absent(),
                required String questionText,
                required String transcript,
                Value<String?> audioPath = const Value.absent(),
                Value<String?> feedbackJson = const Value.absent(),
                Value<double?> score = const Value.absent(),
                required DateTime createdAt,
              }) => TurnsLocalCompanion.insert(
                id: id,
                sessionId: sessionId,
                questionId: questionId,
                questionText: questionText,
                transcript: transcript,
                audioPath: audioPath,
                feedbackJson: feedbackJson,
                score: score,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TurnsLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TurnsLocalTable,
      TurnsLocalData,
      $$TurnsLocalTableFilterComposer,
      $$TurnsLocalTableOrderingComposer,
      $$TurnsLocalTableAnnotationComposer,
      $$TurnsLocalTableCreateCompanionBuilder,
      $$TurnsLocalTableUpdateCompanionBuilder,
      (
        TurnsLocalData,
        BaseReferences<_$AppDatabase, $TurnsLocalTable, TurnsLocalData>,
      ),
      TurnsLocalData,
      PrefetchHooks Function()
    >;
typedef $$ReviewLogsLocalTableCreateCompanionBuilder =
    ReviewLogsLocalCompanion Function({
      Value<int> id,
      required int cardId,
      required int rating,
      required int state,
      required DateTime due,
      required double stability,
      required double difficulty,
      required int elapsedDays,
      required int lastElapsedDays,
      required int scheduledDays,
      required DateTime review,
      Value<bool> isSynced,
    });
typedef $$ReviewLogsLocalTableUpdateCompanionBuilder =
    ReviewLogsLocalCompanion Function({
      Value<int> id,
      Value<int> cardId,
      Value<int> rating,
      Value<int> state,
      Value<DateTime> due,
      Value<double> stability,
      Value<double> difficulty,
      Value<int> elapsedDays,
      Value<int> lastElapsedDays,
      Value<int> scheduledDays,
      Value<DateTime> review,
      Value<bool> isSynced,
    });

class $$ReviewLogsLocalTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewLogsLocalTable> {
  $$ReviewLogsLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get due => $composableBuilder(
    column: $table.due,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedDays => $composableBuilder(
    column: $table.elapsedDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastElapsedDays => $composableBuilder(
    column: $table.lastElapsedDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scheduledDays => $composableBuilder(
    column: $table.scheduledDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get review => $composableBuilder(
    column: $table.review,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReviewLogsLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewLogsLocalTable> {
  $$ReviewLogsLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get due => $composableBuilder(
    column: $table.due,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedDays => $composableBuilder(
    column: $table.elapsedDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastElapsedDays => $composableBuilder(
    column: $table.lastElapsedDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scheduledDays => $composableBuilder(
    column: $table.scheduledDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get review => $composableBuilder(
    column: $table.review,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReviewLogsLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewLogsLocalTable> {
  $$ReviewLogsLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<int> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<DateTime> get due =>
      $composableBuilder(column: $table.due, builder: (column) => column);

  GeneratedColumn<double> get stability =>
      $composableBuilder(column: $table.stability, builder: (column) => column);

  GeneratedColumn<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<int> get elapsedDays => $composableBuilder(
    column: $table.elapsedDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastElapsedDays => $composableBuilder(
    column: $table.lastElapsedDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scheduledDays => $composableBuilder(
    column: $table.scheduledDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get review =>
      $composableBuilder(column: $table.review, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$ReviewLogsLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReviewLogsLocalTable,
          ReviewLogsLocalData,
          $$ReviewLogsLocalTableFilterComposer,
          $$ReviewLogsLocalTableOrderingComposer,
          $$ReviewLogsLocalTableAnnotationComposer,
          $$ReviewLogsLocalTableCreateCompanionBuilder,
          $$ReviewLogsLocalTableUpdateCompanionBuilder,
          (
            ReviewLogsLocalData,
            BaseReferences<
              _$AppDatabase,
              $ReviewLogsLocalTable,
              ReviewLogsLocalData
            >,
          ),
          ReviewLogsLocalData,
          PrefetchHooks Function()
        > {
  $$ReviewLogsLocalTableTableManager(
    _$AppDatabase db,
    $ReviewLogsLocalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewLogsLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewLogsLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewLogsLocalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cardId = const Value.absent(),
                Value<int> rating = const Value.absent(),
                Value<int> state = const Value.absent(),
                Value<DateTime> due = const Value.absent(),
                Value<double> stability = const Value.absent(),
                Value<double> difficulty = const Value.absent(),
                Value<int> elapsedDays = const Value.absent(),
                Value<int> lastElapsedDays = const Value.absent(),
                Value<int> scheduledDays = const Value.absent(),
                Value<DateTime> review = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => ReviewLogsLocalCompanion(
                id: id,
                cardId: cardId,
                rating: rating,
                state: state,
                due: due,
                stability: stability,
                difficulty: difficulty,
                elapsedDays: elapsedDays,
                lastElapsedDays: lastElapsedDays,
                scheduledDays: scheduledDays,
                review: review,
                isSynced: isSynced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cardId,
                required int rating,
                required int state,
                required DateTime due,
                required double stability,
                required double difficulty,
                required int elapsedDays,
                required int lastElapsedDays,
                required int scheduledDays,
                required DateTime review,
                Value<bool> isSynced = const Value.absent(),
              }) => ReviewLogsLocalCompanion.insert(
                id: id,
                cardId: cardId,
                rating: rating,
                state: state,
                due: due,
                stability: stability,
                difficulty: difficulty,
                elapsedDays: elapsedDays,
                lastElapsedDays: lastElapsedDays,
                scheduledDays: scheduledDays,
                review: review,
                isSynced: isSynced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReviewLogsLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReviewLogsLocalTable,
      ReviewLogsLocalData,
      $$ReviewLogsLocalTableFilterComposer,
      $$ReviewLogsLocalTableOrderingComposer,
      $$ReviewLogsLocalTableAnnotationComposer,
      $$ReviewLogsLocalTableCreateCompanionBuilder,
      $$ReviewLogsLocalTableUpdateCompanionBuilder,
      (
        ReviewLogsLocalData,
        BaseReferences<
          _$AppDatabase,
          $ReviewLogsLocalTable,
          ReviewLogsLocalData
        >,
      ),
      ReviewLogsLocalData,
      PrefetchHooks Function()
    >;
typedef $$CardsLocalTableCreateCompanionBuilder =
    CardsLocalCompanion Function({
      Value<int> id,
      Value<int?> mistakeId,
      required String front,
      required String back,
      required double stability,
      required double difficulty,
      required int elapsedDays,
      required int scheduledDays,
      required int reps,
      required int lapses,
      required int state,
      Value<DateTime?> lastReview,
      required DateTime dueDate,
      required DateTime updatedAt,
      Value<String> sourceType,
      Value<String> itemType,
      Value<String?> unitOrPackId,
      Value<String> skill,
      Value<String> userId,
    });
typedef $$CardsLocalTableUpdateCompanionBuilder =
    CardsLocalCompanion Function({
      Value<int> id,
      Value<int?> mistakeId,
      Value<String> front,
      Value<String> back,
      Value<double> stability,
      Value<double> difficulty,
      Value<int> elapsedDays,
      Value<int> scheduledDays,
      Value<int> reps,
      Value<int> lapses,
      Value<int> state,
      Value<DateTime?> lastReview,
      Value<DateTime> dueDate,
      Value<DateTime> updatedAt,
      Value<String> sourceType,
      Value<String> itemType,
      Value<String?> unitOrPackId,
      Value<String> skill,
      Value<String> userId,
    });

class $$CardsLocalTableFilterComposer
    extends Composer<_$AppDatabase, $CardsLocalTable> {
  $$CardsLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mistakeId => $composableBuilder(
    column: $table.mistakeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get front => $composableBuilder(
    column: $table.front,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get back => $composableBuilder(
    column: $table.back,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedDays => $composableBuilder(
    column: $table.elapsedDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scheduledDays => $composableBuilder(
    column: $table.scheduledDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lapses => $composableBuilder(
    column: $table.lapses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReview => $composableBuilder(
    column: $table.lastReview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitOrPackId => $composableBuilder(
    column: $table.unitOrPackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get skill => $composableBuilder(
    column: $table.skill,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CardsLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $CardsLocalTable> {
  $$CardsLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mistakeId => $composableBuilder(
    column: $table.mistakeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get front => $composableBuilder(
    column: $table.front,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get back => $composableBuilder(
    column: $table.back,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedDays => $composableBuilder(
    column: $table.elapsedDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scheduledDays => $composableBuilder(
    column: $table.scheduledDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lapses => $composableBuilder(
    column: $table.lapses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReview => $composableBuilder(
    column: $table.lastReview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitOrPackId => $composableBuilder(
    column: $table.unitOrPackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get skill => $composableBuilder(
    column: $table.skill,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CardsLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardsLocalTable> {
  $$CardsLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get mistakeId =>
      $composableBuilder(column: $table.mistakeId, builder: (column) => column);

  GeneratedColumn<String> get front =>
      $composableBuilder(column: $table.front, builder: (column) => column);

  GeneratedColumn<String> get back =>
      $composableBuilder(column: $table.back, builder: (column) => column);

  GeneratedColumn<double> get stability =>
      $composableBuilder(column: $table.stability, builder: (column) => column);

  GeneratedColumn<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<int> get elapsedDays => $composableBuilder(
    column: $table.elapsedDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scheduledDays => $composableBuilder(
    column: $table.scheduledDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get lapses =>
      $composableBuilder(column: $table.lapses, builder: (column) => column);

  GeneratedColumn<int> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReview => $composableBuilder(
    column: $table.lastReview,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get itemType =>
      $composableBuilder(column: $table.itemType, builder: (column) => column);

  GeneratedColumn<String> get unitOrPackId => $composableBuilder(
    column: $table.unitOrPackId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get skill =>
      $composableBuilder(column: $table.skill, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);
}

class $$CardsLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardsLocalTable,
          CardsLocalData,
          $$CardsLocalTableFilterComposer,
          $$CardsLocalTableOrderingComposer,
          $$CardsLocalTableAnnotationComposer,
          $$CardsLocalTableCreateCompanionBuilder,
          $$CardsLocalTableUpdateCompanionBuilder,
          (
            CardsLocalData,
            BaseReferences<_$AppDatabase, $CardsLocalTable, CardsLocalData>,
          ),
          CardsLocalData,
          PrefetchHooks Function()
        > {
  $$CardsLocalTableTableManager(_$AppDatabase db, $CardsLocalTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardsLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardsLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardsLocalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> mistakeId = const Value.absent(),
                Value<String> front = const Value.absent(),
                Value<String> back = const Value.absent(),
                Value<double> stability = const Value.absent(),
                Value<double> difficulty = const Value.absent(),
                Value<int> elapsedDays = const Value.absent(),
                Value<int> scheduledDays = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<int> lapses = const Value.absent(),
                Value<int> state = const Value.absent(),
                Value<DateTime?> lastReview = const Value.absent(),
                Value<DateTime> dueDate = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<String> itemType = const Value.absent(),
                Value<String?> unitOrPackId = const Value.absent(),
                Value<String> skill = const Value.absent(),
                Value<String> userId = const Value.absent(),
              }) => CardsLocalCompanion(
                id: id,
                mistakeId: mistakeId,
                front: front,
                back: back,
                stability: stability,
                difficulty: difficulty,
                elapsedDays: elapsedDays,
                scheduledDays: scheduledDays,
                reps: reps,
                lapses: lapses,
                state: state,
                lastReview: lastReview,
                dueDate: dueDate,
                updatedAt: updatedAt,
                sourceType: sourceType,
                itemType: itemType,
                unitOrPackId: unitOrPackId,
                skill: skill,
                userId: userId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> mistakeId = const Value.absent(),
                required String front,
                required String back,
                required double stability,
                required double difficulty,
                required int elapsedDays,
                required int scheduledDays,
                required int reps,
                required int lapses,
                required int state,
                Value<DateTime?> lastReview = const Value.absent(),
                required DateTime dueDate,
                required DateTime updatedAt,
                Value<String> sourceType = const Value.absent(),
                Value<String> itemType = const Value.absent(),
                Value<String?> unitOrPackId = const Value.absent(),
                Value<String> skill = const Value.absent(),
                Value<String> userId = const Value.absent(),
              }) => CardsLocalCompanion.insert(
                id: id,
                mistakeId: mistakeId,
                front: front,
                back: back,
                stability: stability,
                difficulty: difficulty,
                elapsedDays: elapsedDays,
                scheduledDays: scheduledDays,
                reps: reps,
                lapses: lapses,
                state: state,
                lastReview: lastReview,
                dueDate: dueDate,
                updatedAt: updatedAt,
                sourceType: sourceType,
                itemType: itemType,
                unitOrPackId: unitOrPackId,
                skill: skill,
                userId: userId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CardsLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardsLocalTable,
      CardsLocalData,
      $$CardsLocalTableFilterComposer,
      $$CardsLocalTableOrderingComposer,
      $$CardsLocalTableAnnotationComposer,
      $$CardsLocalTableCreateCompanionBuilder,
      $$CardsLocalTableUpdateCompanionBuilder,
      (
        CardsLocalData,
        BaseReferences<_$AppDatabase, $CardsLocalTable, CardsLocalData>,
      ),
      CardsLocalData,
      PrefetchHooks Function()
    >;
typedef $$QueueItemsTableCreateCompanionBuilder =
    QueueItemsCompanion Function({
      required String id,
      required String sessionId,
      Value<int?> questionId,
      required String audioPath,
      required DateTime createdAt,
      Value<int> retryCount,
      Value<String?> lastError,
      Value<String> status,
      Value<int> rowid,
    });
typedef $$QueueItemsTableUpdateCompanionBuilder =
    QueueItemsCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<int?> questionId,
      Value<String> audioPath,
      Value<DateTime> createdAt,
      Value<int> retryCount,
      Value<String?> lastError,
      Value<String> status,
      Value<int> rowid,
    });

class $$QueueItemsTableFilterComposer
    extends Composer<_$AppDatabase, $QueueItemsTable> {
  $$QueueItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QueueItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $QueueItemsTable> {
  $$QueueItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QueueItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QueueItemsTable> {
  $$QueueItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<int> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get audioPath =>
      $composableBuilder(column: $table.audioPath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$QueueItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QueueItemsTable,
          QueueItem,
          $$QueueItemsTableFilterComposer,
          $$QueueItemsTableOrderingComposer,
          $$QueueItemsTableAnnotationComposer,
          $$QueueItemsTableCreateCompanionBuilder,
          $$QueueItemsTableUpdateCompanionBuilder,
          (
            QueueItem,
            BaseReferences<_$AppDatabase, $QueueItemsTable, QueueItem>,
          ),
          QueueItem,
          PrefetchHooks Function()
        > {
  $$QueueItemsTableTableManager(_$AppDatabase db, $QueueItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QueueItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QueueItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QueueItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<int?> questionId = const Value.absent(),
                Value<String> audioPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QueueItemsCompanion(
                id: id,
                sessionId: sessionId,
                questionId: questionId,
                audioPath: audioPath,
                createdAt: createdAt,
                retryCount: retryCount,
                lastError: lastError,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                Value<int?> questionId = const Value.absent(),
                required String audioPath,
                required DateTime createdAt,
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QueueItemsCompanion.insert(
                id: id,
                sessionId: sessionId,
                questionId: questionId,
                audioPath: audioPath,
                createdAt: createdAt,
                retryCount: retryCount,
                lastError: lastError,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QueueItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QueueItemsTable,
      QueueItem,
      $$QueueItemsTableFilterComposer,
      $$QueueItemsTableOrderingComposer,
      $$QueueItemsTableAnnotationComposer,
      $$QueueItemsTableCreateCompanionBuilder,
      $$QueueItemsTableUpdateCompanionBuilder,
      (QueueItem, BaseReferences<_$AppDatabase, $QueueItemsTable, QueueItem>),
      QueueItem,
      PrefetchHooks Function()
    >;
typedef $$JournalEntriesTableCreateCompanionBuilder =
    JournalEntriesCompanion Function({
      required String id,
      required String sessionId,
      required String title,
      required DateTime date,
      required int durationSeconds,
      required int questionsCount,
      required double overallScore,
      required int mistakesCount,
      required String mistakesJson,
      required String vocabularyJson,
      required String markdownContent,
      Value<bool> isExported,
      Value<int> rowid,
    });
typedef $$JournalEntriesTableUpdateCompanionBuilder =
    JournalEntriesCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> title,
      Value<DateTime> date,
      Value<int> durationSeconds,
      Value<int> questionsCount,
      Value<double> overallScore,
      Value<int> mistakesCount,
      Value<String> mistakesJson,
      Value<String> vocabularyJson,
      Value<String> markdownContent,
      Value<bool> isExported,
      Value<int> rowid,
    });

class $$JournalEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get questionsCount => $composableBuilder(
    column: $table.questionsCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get overallScore => $composableBuilder(
    column: $table.overallScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mistakesCount => $composableBuilder(
    column: $table.mistakesCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mistakesJson => $composableBuilder(
    column: $table.mistakesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vocabularyJson => $composableBuilder(
    column: $table.vocabularyJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get markdownContent => $composableBuilder(
    column: $table.markdownContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isExported => $composableBuilder(
    column: $table.isExported,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JournalEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get questionsCount => $composableBuilder(
    column: $table.questionsCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get overallScore => $composableBuilder(
    column: $table.overallScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mistakesCount => $composableBuilder(
    column: $table.mistakesCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mistakesJson => $composableBuilder(
    column: $table.mistakesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vocabularyJson => $composableBuilder(
    column: $table.vocabularyJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get markdownContent => $composableBuilder(
    column: $table.markdownContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isExported => $composableBuilder(
    column: $table.isExported,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JournalEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get questionsCount => $composableBuilder(
    column: $table.questionsCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get overallScore => $composableBuilder(
    column: $table.overallScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get mistakesCount => $composableBuilder(
    column: $table.mistakesCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mistakesJson => $composableBuilder(
    column: $table.mistakesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vocabularyJson => $composableBuilder(
    column: $table.vocabularyJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get markdownContent => $composableBuilder(
    column: $table.markdownContent,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isExported => $composableBuilder(
    column: $table.isExported,
    builder: (column) => column,
  );
}

class $$JournalEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JournalEntriesTable,
          JournalEntry,
          $$JournalEntriesTableFilterComposer,
          $$JournalEntriesTableOrderingComposer,
          $$JournalEntriesTableAnnotationComposer,
          $$JournalEntriesTableCreateCompanionBuilder,
          $$JournalEntriesTableUpdateCompanionBuilder,
          (
            JournalEntry,
            BaseReferences<_$AppDatabase, $JournalEntriesTable, JournalEntry>,
          ),
          JournalEntry,
          PrefetchHooks Function()
        > {
  $$JournalEntriesTableTableManager(
    _$AppDatabase db,
    $JournalEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<int> questionsCount = const Value.absent(),
                Value<double> overallScore = const Value.absent(),
                Value<int> mistakesCount = const Value.absent(),
                Value<String> mistakesJson = const Value.absent(),
                Value<String> vocabularyJson = const Value.absent(),
                Value<String> markdownContent = const Value.absent(),
                Value<bool> isExported = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JournalEntriesCompanion(
                id: id,
                sessionId: sessionId,
                title: title,
                date: date,
                durationSeconds: durationSeconds,
                questionsCount: questionsCount,
                overallScore: overallScore,
                mistakesCount: mistakesCount,
                mistakesJson: mistakesJson,
                vocabularyJson: vocabularyJson,
                markdownContent: markdownContent,
                isExported: isExported,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String title,
                required DateTime date,
                required int durationSeconds,
                required int questionsCount,
                required double overallScore,
                required int mistakesCount,
                required String mistakesJson,
                required String vocabularyJson,
                required String markdownContent,
                Value<bool> isExported = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JournalEntriesCompanion.insert(
                id: id,
                sessionId: sessionId,
                title: title,
                date: date,
                durationSeconds: durationSeconds,
                questionsCount: questionsCount,
                overallScore: overallScore,
                mistakesCount: mistakesCount,
                mistakesJson: mistakesJson,
                vocabularyJson: vocabularyJson,
                markdownContent: markdownContent,
                isExported: isExported,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JournalEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JournalEntriesTable,
      JournalEntry,
      $$JournalEntriesTableFilterComposer,
      $$JournalEntriesTableOrderingComposer,
      $$JournalEntriesTableAnnotationComposer,
      $$JournalEntriesTableCreateCompanionBuilder,
      $$JournalEntriesTableUpdateCompanionBuilder,
      (
        JournalEntry,
        BaseReferences<_$AppDatabase, $JournalEntriesTable, JournalEntry>,
      ),
      JournalEntry,
      PrefetchHooks Function()
    >;
typedef $$UserMilestonesLocalTableCreateCompanionBuilder =
    UserMilestonesLocalCompanion Function({
      required String id,
      required String title,
      required String description,
      Value<bool> achieved,
      Value<DateTime?> achievedAt,
      Value<String?> value,
      Value<int> rowid,
    });
typedef $$UserMilestonesLocalTableUpdateCompanionBuilder =
    UserMilestonesLocalCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> description,
      Value<bool> achieved,
      Value<DateTime?> achievedAt,
      Value<String?> value,
      Value<int> rowid,
    });

class $$UserMilestonesLocalTableFilterComposer
    extends Composer<_$AppDatabase, $UserMilestonesLocalTable> {
  $$UserMilestonesLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get achieved => $composableBuilder(
    column: $table.achieved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserMilestonesLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $UserMilestonesLocalTable> {
  $$UserMilestonesLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get achieved => $composableBuilder(
    column: $table.achieved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserMilestonesLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserMilestonesLocalTable> {
  $$UserMilestonesLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get achieved =>
      $composableBuilder(column: $table.achieved, builder: (column) => column);

  GeneratedColumn<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$UserMilestonesLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserMilestonesLocalTable,
          UserMilestonesLocalData,
          $$UserMilestonesLocalTableFilterComposer,
          $$UserMilestonesLocalTableOrderingComposer,
          $$UserMilestonesLocalTableAnnotationComposer,
          $$UserMilestonesLocalTableCreateCompanionBuilder,
          $$UserMilestonesLocalTableUpdateCompanionBuilder,
          (
            UserMilestonesLocalData,
            BaseReferences<
              _$AppDatabase,
              $UserMilestonesLocalTable,
              UserMilestonesLocalData
            >,
          ),
          UserMilestonesLocalData,
          PrefetchHooks Function()
        > {
  $$UserMilestonesLocalTableTableManager(
    _$AppDatabase db,
    $UserMilestonesLocalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserMilestonesLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserMilestonesLocalTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UserMilestonesLocalTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<bool> achieved = const Value.absent(),
                Value<DateTime?> achievedAt = const Value.absent(),
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserMilestonesLocalCompanion(
                id: id,
                title: title,
                description: description,
                achieved: achieved,
                achievedAt: achievedAt,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String description,
                Value<bool> achieved = const Value.absent(),
                Value<DateTime?> achievedAt = const Value.absent(),
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserMilestonesLocalCompanion.insert(
                id: id,
                title: title,
                description: description,
                achieved: achieved,
                achievedAt: achievedAt,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserMilestonesLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserMilestonesLocalTable,
      UserMilestonesLocalData,
      $$UserMilestonesLocalTableFilterComposer,
      $$UserMilestonesLocalTableOrderingComposer,
      $$UserMilestonesLocalTableAnnotationComposer,
      $$UserMilestonesLocalTableCreateCompanionBuilder,
      $$UserMilestonesLocalTableUpdateCompanionBuilder,
      (
        UserMilestonesLocalData,
        BaseReferences<
          _$AppDatabase,
          $UserMilestonesLocalTable,
          UserMilestonesLocalData
        >,
      ),
      UserMilestonesLocalData,
      PrefetchHooks Function()
    >;
typedef $$ResourcesLocalTableCreateCompanionBuilder =
    ResourcesLocalCompanion Function({
      required String id,
      required String title,
      required String originalUrl,
      required String sourceName,
      required String resourceType,
      required String skill,
      required String domain,
      required String level,
      required String tagsJson,
      Value<bool> transcriptAvailable,
      Value<bool> spanishSupport,
      Value<int> estimatedMinutes,
      Value<String?> recommendedFor,
      Value<String?> spanishNotes,
      Value<String?> collectionId,
      Value<int> rowid,
    });
typedef $$ResourcesLocalTableUpdateCompanionBuilder =
    ResourcesLocalCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> originalUrl,
      Value<String> sourceName,
      Value<String> resourceType,
      Value<String> skill,
      Value<String> domain,
      Value<String> level,
      Value<String> tagsJson,
      Value<bool> transcriptAvailable,
      Value<bool> spanishSupport,
      Value<int> estimatedMinutes,
      Value<String?> recommendedFor,
      Value<String?> spanishNotes,
      Value<String?> collectionId,
      Value<int> rowid,
    });

class $$ResourcesLocalTableFilterComposer
    extends Composer<_$AppDatabase, $ResourcesLocalTable> {
  $$ResourcesLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalUrl => $composableBuilder(
    column: $table.originalUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resourceType => $composableBuilder(
    column: $table.resourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get skill => $composableBuilder(
    column: $table.skill,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get transcriptAvailable => $composableBuilder(
    column: $table.transcriptAvailable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get spanishSupport => $composableBuilder(
    column: $table.spanishSupport,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recommendedFor => $composableBuilder(
    column: $table.recommendedFor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get spanishNotes => $composableBuilder(
    column: $table.spanishNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ResourcesLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $ResourcesLocalTable> {
  $$ResourcesLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalUrl => $composableBuilder(
    column: $table.originalUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resourceType => $composableBuilder(
    column: $table.resourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get skill => $composableBuilder(
    column: $table.skill,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get transcriptAvailable => $composableBuilder(
    column: $table.transcriptAvailable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get spanishSupport => $composableBuilder(
    column: $table.spanishSupport,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recommendedFor => $composableBuilder(
    column: $table.recommendedFor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spanishNotes => $composableBuilder(
    column: $table.spanishNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ResourcesLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResourcesLocalTable> {
  $$ResourcesLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get originalUrl => $composableBuilder(
    column: $table.originalUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resourceType => $composableBuilder(
    column: $table.resourceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get skill =>
      $composableBuilder(column: $table.skill, builder: (column) => column);

  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<bool> get transcriptAvailable => $composableBuilder(
    column: $table.transcriptAvailable,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get spanishSupport => $composableBuilder(
    column: $table.spanishSupport,
    builder: (column) => column,
  );

  GeneratedColumn<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recommendedFor => $composableBuilder(
    column: $table.recommendedFor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get spanishNotes => $composableBuilder(
    column: $table.spanishNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => column,
  );
}

class $$ResourcesLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ResourcesLocalTable,
          ResourcesLocalData,
          $$ResourcesLocalTableFilterComposer,
          $$ResourcesLocalTableOrderingComposer,
          $$ResourcesLocalTableAnnotationComposer,
          $$ResourcesLocalTableCreateCompanionBuilder,
          $$ResourcesLocalTableUpdateCompanionBuilder,
          (
            ResourcesLocalData,
            BaseReferences<
              _$AppDatabase,
              $ResourcesLocalTable,
              ResourcesLocalData
            >,
          ),
          ResourcesLocalData,
          PrefetchHooks Function()
        > {
  $$ResourcesLocalTableTableManager(
    _$AppDatabase db,
    $ResourcesLocalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResourcesLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResourcesLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResourcesLocalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> originalUrl = const Value.absent(),
                Value<String> sourceName = const Value.absent(),
                Value<String> resourceType = const Value.absent(),
                Value<String> skill = const Value.absent(),
                Value<String> domain = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String> tagsJson = const Value.absent(),
                Value<bool> transcriptAvailable = const Value.absent(),
                Value<bool> spanishSupport = const Value.absent(),
                Value<int> estimatedMinutes = const Value.absent(),
                Value<String?> recommendedFor = const Value.absent(),
                Value<String?> spanishNotes = const Value.absent(),
                Value<String?> collectionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ResourcesLocalCompanion(
                id: id,
                title: title,
                originalUrl: originalUrl,
                sourceName: sourceName,
                resourceType: resourceType,
                skill: skill,
                domain: domain,
                level: level,
                tagsJson: tagsJson,
                transcriptAvailable: transcriptAvailable,
                spanishSupport: spanishSupport,
                estimatedMinutes: estimatedMinutes,
                recommendedFor: recommendedFor,
                spanishNotes: spanishNotes,
                collectionId: collectionId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String originalUrl,
                required String sourceName,
                required String resourceType,
                required String skill,
                required String domain,
                required String level,
                required String tagsJson,
                Value<bool> transcriptAvailable = const Value.absent(),
                Value<bool> spanishSupport = const Value.absent(),
                Value<int> estimatedMinutes = const Value.absent(),
                Value<String?> recommendedFor = const Value.absent(),
                Value<String?> spanishNotes = const Value.absent(),
                Value<String?> collectionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ResourcesLocalCompanion.insert(
                id: id,
                title: title,
                originalUrl: originalUrl,
                sourceName: sourceName,
                resourceType: resourceType,
                skill: skill,
                domain: domain,
                level: level,
                tagsJson: tagsJson,
                transcriptAvailable: transcriptAvailable,
                spanishSupport: spanishSupport,
                estimatedMinutes: estimatedMinutes,
                recommendedFor: recommendedFor,
                spanishNotes: spanishNotes,
                collectionId: collectionId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ResourcesLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ResourcesLocalTable,
      ResourcesLocalData,
      $$ResourcesLocalTableFilterComposer,
      $$ResourcesLocalTableOrderingComposer,
      $$ResourcesLocalTableAnnotationComposer,
      $$ResourcesLocalTableCreateCompanionBuilder,
      $$ResourcesLocalTableUpdateCompanionBuilder,
      (
        ResourcesLocalData,
        BaseReferences<_$AppDatabase, $ResourcesLocalTable, ResourcesLocalData>,
      ),
      ResourcesLocalData,
      PrefetchHooks Function()
    >;
typedef $$ResourceCollectionsLocalTableCreateCompanionBuilder =
    ResourceCollectionsLocalCompanion Function({
      required String id,
      required String name,
      Value<String?> description,
      Value<String> icon,
      Value<String> color,
      Value<int> orderIndex,
      Value<int> rowid,
    });
typedef $$ResourceCollectionsLocalTableUpdateCompanionBuilder =
    ResourceCollectionsLocalCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> description,
      Value<String> icon,
      Value<String> color,
      Value<int> orderIndex,
      Value<int> rowid,
    });

class $$ResourceCollectionsLocalTableFilterComposer
    extends Composer<_$AppDatabase, $ResourceCollectionsLocalTable> {
  $$ResourceCollectionsLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ResourceCollectionsLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $ResourceCollectionsLocalTable> {
  $$ResourceCollectionsLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ResourceCollectionsLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResourceCollectionsLocalTable> {
  $$ResourceCollectionsLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );
}

class $$ResourceCollectionsLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ResourceCollectionsLocalTable,
          ResourceCollectionsLocalData,
          $$ResourceCollectionsLocalTableFilterComposer,
          $$ResourceCollectionsLocalTableOrderingComposer,
          $$ResourceCollectionsLocalTableAnnotationComposer,
          $$ResourceCollectionsLocalTableCreateCompanionBuilder,
          $$ResourceCollectionsLocalTableUpdateCompanionBuilder,
          (
            ResourceCollectionsLocalData,
            BaseReferences<
              _$AppDatabase,
              $ResourceCollectionsLocalTable,
              ResourceCollectionsLocalData
            >,
          ),
          ResourceCollectionsLocalData,
          PrefetchHooks Function()
        > {
  $$ResourceCollectionsLocalTableTableManager(
    _$AppDatabase db,
    $ResourceCollectionsLocalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResourceCollectionsLocalTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ResourceCollectionsLocalTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ResourceCollectionsLocalTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ResourceCollectionsLocalCompanion(
                id: id,
                name: name,
                description: description,
                icon: icon,
                color: color,
                orderIndex: orderIndex,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ResourceCollectionsLocalCompanion.insert(
                id: id,
                name: name,
                description: description,
                icon: icon,
                color: color,
                orderIndex: orderIndex,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ResourceCollectionsLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ResourceCollectionsLocalTable,
      ResourceCollectionsLocalData,
      $$ResourceCollectionsLocalTableFilterComposer,
      $$ResourceCollectionsLocalTableOrderingComposer,
      $$ResourceCollectionsLocalTableAnnotationComposer,
      $$ResourceCollectionsLocalTableCreateCompanionBuilder,
      $$ResourceCollectionsLocalTableUpdateCompanionBuilder,
      (
        ResourceCollectionsLocalData,
        BaseReferences<
          _$AppDatabase,
          $ResourceCollectionsLocalTable,
          ResourceCollectionsLocalData
        >,
      ),
      ResourceCollectionsLocalData,
      PrefetchHooks Function()
    >;
typedef $$UnitResourceLinksLocalTableCreateCompanionBuilder =
    UnitResourceLinksLocalCompanion Function({
      Value<int> id,
      required String resourceId,
      required String targetType,
      required String targetId,
      Value<String?> relevanceNote,
    });
typedef $$UnitResourceLinksLocalTableUpdateCompanionBuilder =
    UnitResourceLinksLocalCompanion Function({
      Value<int> id,
      Value<String> resourceId,
      Value<String> targetType,
      Value<String> targetId,
      Value<String?> relevanceNote,
    });

class $$UnitResourceLinksLocalTableFilterComposer
    extends Composer<_$AppDatabase, $UnitResourceLinksLocalTable> {
  $$UnitResourceLinksLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relevanceNote => $composableBuilder(
    column: $table.relevanceNote,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UnitResourceLinksLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $UnitResourceLinksLocalTable> {
  $$UnitResourceLinksLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relevanceNote => $composableBuilder(
    column: $table.relevanceNote,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UnitResourceLinksLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $UnitResourceLinksLocalTable> {
  $$UnitResourceLinksLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<String> get relevanceNote => $composableBuilder(
    column: $table.relevanceNote,
    builder: (column) => column,
  );
}

class $$UnitResourceLinksLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UnitResourceLinksLocalTable,
          UnitResourceLinksLocalData,
          $$UnitResourceLinksLocalTableFilterComposer,
          $$UnitResourceLinksLocalTableOrderingComposer,
          $$UnitResourceLinksLocalTableAnnotationComposer,
          $$UnitResourceLinksLocalTableCreateCompanionBuilder,
          $$UnitResourceLinksLocalTableUpdateCompanionBuilder,
          (
            UnitResourceLinksLocalData,
            BaseReferences<
              _$AppDatabase,
              $UnitResourceLinksLocalTable,
              UnitResourceLinksLocalData
            >,
          ),
          UnitResourceLinksLocalData,
          PrefetchHooks Function()
        > {
  $$UnitResourceLinksLocalTableTableManager(
    _$AppDatabase db,
    $UnitResourceLinksLocalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UnitResourceLinksLocalTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$UnitResourceLinksLocalTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UnitResourceLinksLocalTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> resourceId = const Value.absent(),
                Value<String> targetType = const Value.absent(),
                Value<String> targetId = const Value.absent(),
                Value<String?> relevanceNote = const Value.absent(),
              }) => UnitResourceLinksLocalCompanion(
                id: id,
                resourceId: resourceId,
                targetType: targetType,
                targetId: targetId,
                relevanceNote: relevanceNote,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String resourceId,
                required String targetType,
                required String targetId,
                Value<String?> relevanceNote = const Value.absent(),
              }) => UnitResourceLinksLocalCompanion.insert(
                id: id,
                resourceId: resourceId,
                targetType: targetType,
                targetId: targetId,
                relevanceNote: relevanceNote,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UnitResourceLinksLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UnitResourceLinksLocalTable,
      UnitResourceLinksLocalData,
      $$UnitResourceLinksLocalTableFilterComposer,
      $$UnitResourceLinksLocalTableOrderingComposer,
      $$UnitResourceLinksLocalTableAnnotationComposer,
      $$UnitResourceLinksLocalTableCreateCompanionBuilder,
      $$UnitResourceLinksLocalTableUpdateCompanionBuilder,
      (
        UnitResourceLinksLocalData,
        BaseReferences<
          _$AppDatabase,
          $UnitResourceLinksLocalTable,
          UnitResourceLinksLocalData
        >,
      ),
      UnitResourceLinksLocalData,
      PrefetchHooks Function()
    >;
typedef $$ResourceUsageLogsLocalTableCreateCompanionBuilder =
    ResourceUsageLogsLocalCompanion Function({
      Value<int> id,
      required String resourceId,
      Value<String?> unitId,
      Value<String> eventType,
      Value<int> durationSeconds,
      required DateTime createdAt,
      Value<bool> isSynced,
    });
typedef $$ResourceUsageLogsLocalTableUpdateCompanionBuilder =
    ResourceUsageLogsLocalCompanion Function({
      Value<int> id,
      Value<String> resourceId,
      Value<String?> unitId,
      Value<String> eventType,
      Value<int> durationSeconds,
      Value<DateTime> createdAt,
      Value<bool> isSynced,
    });

class $$ResourceUsageLogsLocalTableFilterComposer
    extends Composer<_$AppDatabase, $ResourceUsageLogsLocalTable> {
  $$ResourceUsageLogsLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitId => $composableBuilder(
    column: $table.unitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ResourceUsageLogsLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $ResourceUsageLogsLocalTable> {
  $$ResourceUsageLogsLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitId => $composableBuilder(
    column: $table.unitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ResourceUsageLogsLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResourceUsageLogsLocalTable> {
  $$ResourceUsageLogsLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unitId =>
      $composableBuilder(column: $table.unitId, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$ResourceUsageLogsLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ResourceUsageLogsLocalTable,
          ResourceUsageLogsLocalData,
          $$ResourceUsageLogsLocalTableFilterComposer,
          $$ResourceUsageLogsLocalTableOrderingComposer,
          $$ResourceUsageLogsLocalTableAnnotationComposer,
          $$ResourceUsageLogsLocalTableCreateCompanionBuilder,
          $$ResourceUsageLogsLocalTableUpdateCompanionBuilder,
          (
            ResourceUsageLogsLocalData,
            BaseReferences<
              _$AppDatabase,
              $ResourceUsageLogsLocalTable,
              ResourceUsageLogsLocalData
            >,
          ),
          ResourceUsageLogsLocalData,
          PrefetchHooks Function()
        > {
  $$ResourceUsageLogsLocalTableTableManager(
    _$AppDatabase db,
    $ResourceUsageLogsLocalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResourceUsageLogsLocalTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ResourceUsageLogsLocalTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ResourceUsageLogsLocalTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> resourceId = const Value.absent(),
                Value<String?> unitId = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => ResourceUsageLogsLocalCompanion(
                id: id,
                resourceId: resourceId,
                unitId: unitId,
                eventType: eventType,
                durationSeconds: durationSeconds,
                createdAt: createdAt,
                isSynced: isSynced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String resourceId,
                Value<String?> unitId = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                required DateTime createdAt,
                Value<bool> isSynced = const Value.absent(),
              }) => ResourceUsageLogsLocalCompanion.insert(
                id: id,
                resourceId: resourceId,
                unitId: unitId,
                eventType: eventType,
                durationSeconds: durationSeconds,
                createdAt: createdAt,
                isSynced: isSynced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ResourceUsageLogsLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ResourceUsageLogsLocalTable,
      ResourceUsageLogsLocalData,
      $$ResourceUsageLogsLocalTableFilterComposer,
      $$ResourceUsageLogsLocalTableOrderingComposer,
      $$ResourceUsageLogsLocalTableAnnotationComposer,
      $$ResourceUsageLogsLocalTableCreateCompanionBuilder,
      $$ResourceUsageLogsLocalTableUpdateCompanionBuilder,
      (
        ResourceUsageLogsLocalData,
        BaseReferences<
          _$AppDatabase,
          $ResourceUsageLogsLocalTable,
          ResourceUsageLogsLocalData
        >,
      ),
      ResourceUsageLogsLocalData,
      PrefetchHooks Function()
    >;
typedef $$UserProfilesLocalTableCreateCompanionBuilder =
    UserProfilesLocalCompanion Function({
      required String id,
      required String displayName,
      Value<String?> email,
      Value<String?> avatarUrl,
      Value<String> targetLevel,
      Value<String> roleTitle,
      Value<String> learningGoal,
      Value<int> dailyGoalMinutes,
      Value<int> totalXp,
      Value<int> streakDays,
      Value<DateTime?> lastActiveDate,
      required DateTime createdAt,
      Value<bool> isCurrent,
      Value<int> rowid,
    });
typedef $$UserProfilesLocalTableUpdateCompanionBuilder =
    UserProfilesLocalCompanion Function({
      Value<String> id,
      Value<String> displayName,
      Value<String?> email,
      Value<String?> avatarUrl,
      Value<String> targetLevel,
      Value<String> roleTitle,
      Value<String> learningGoal,
      Value<int> dailyGoalMinutes,
      Value<int> totalXp,
      Value<int> streakDays,
      Value<DateTime?> lastActiveDate,
      Value<DateTime> createdAt,
      Value<bool> isCurrent,
      Value<int> rowid,
    });

class $$UserProfilesLocalTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesLocalTable> {
  $$UserProfilesLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetLevel => $composableBuilder(
    column: $table.targetLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roleTitle => $composableBuilder(
    column: $table.roleTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get learningGoal => $composableBuilder(
    column: $table.learningGoal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyGoalMinutes => $composableBuilder(
    column: $table.dailyGoalMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalXp => $composableBuilder(
    column: $table.totalXp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get streakDays => $composableBuilder(
    column: $table.streakDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastActiveDate => $composableBuilder(
    column: $table.lastActiveDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCurrent => $composableBuilder(
    column: $table.isCurrent,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesLocalTable> {
  $$UserProfilesLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetLevel => $composableBuilder(
    column: $table.targetLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roleTitle => $composableBuilder(
    column: $table.roleTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get learningGoal => $composableBuilder(
    column: $table.learningGoal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyGoalMinutes => $composableBuilder(
    column: $table.dailyGoalMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalXp => $composableBuilder(
    column: $table.totalXp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get streakDays => $composableBuilder(
    column: $table.streakDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastActiveDate => $composableBuilder(
    column: $table.lastActiveDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCurrent => $composableBuilder(
    column: $table.isCurrent,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesLocalTable> {
  $$UserProfilesLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<String> get targetLevel => $composableBuilder(
    column: $table.targetLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get roleTitle =>
      $composableBuilder(column: $table.roleTitle, builder: (column) => column);

  GeneratedColumn<String> get learningGoal => $composableBuilder(
    column: $table.learningGoal,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dailyGoalMinutes => $composableBuilder(
    column: $table.dailyGoalMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalXp =>
      $composableBuilder(column: $table.totalXp, builder: (column) => column);

  GeneratedColumn<int> get streakDays => $composableBuilder(
    column: $table.streakDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastActiveDate => $composableBuilder(
    column: $table.lastActiveDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isCurrent =>
      $composableBuilder(column: $table.isCurrent, builder: (column) => column);
}

class $$UserProfilesLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesLocalTable,
          UserProfilesLocalData,
          $$UserProfilesLocalTableFilterComposer,
          $$UserProfilesLocalTableOrderingComposer,
          $$UserProfilesLocalTableAnnotationComposer,
          $$UserProfilesLocalTableCreateCompanionBuilder,
          $$UserProfilesLocalTableUpdateCompanionBuilder,
          (
            UserProfilesLocalData,
            BaseReferences<
              _$AppDatabase,
              $UserProfilesLocalTable,
              UserProfilesLocalData
            >,
          ),
          UserProfilesLocalData,
          PrefetchHooks Function()
        > {
  $$UserProfilesLocalTableTableManager(
    _$AppDatabase db,
    $UserProfilesLocalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesLocalTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<String> targetLevel = const Value.absent(),
                Value<String> roleTitle = const Value.absent(),
                Value<String> learningGoal = const Value.absent(),
                Value<int> dailyGoalMinutes = const Value.absent(),
                Value<int> totalXp = const Value.absent(),
                Value<int> streakDays = const Value.absent(),
                Value<DateTime?> lastActiveDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isCurrent = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesLocalCompanion(
                id: id,
                displayName: displayName,
                email: email,
                avatarUrl: avatarUrl,
                targetLevel: targetLevel,
                roleTitle: roleTitle,
                learningGoal: learningGoal,
                dailyGoalMinutes: dailyGoalMinutes,
                totalXp: totalXp,
                streakDays: streakDays,
                lastActiveDate: lastActiveDate,
                createdAt: createdAt,
                isCurrent: isCurrent,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String displayName,
                Value<String?> email = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<String> targetLevel = const Value.absent(),
                Value<String> roleTitle = const Value.absent(),
                Value<String> learningGoal = const Value.absent(),
                Value<int> dailyGoalMinutes = const Value.absent(),
                Value<int> totalXp = const Value.absent(),
                Value<int> streakDays = const Value.absent(),
                Value<DateTime?> lastActiveDate = const Value.absent(),
                required DateTime createdAt,
                Value<bool> isCurrent = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesLocalCompanion.insert(
                id: id,
                displayName: displayName,
                email: email,
                avatarUrl: avatarUrl,
                targetLevel: targetLevel,
                roleTitle: roleTitle,
                learningGoal: learningGoal,
                dailyGoalMinutes: dailyGoalMinutes,
                totalXp: totalXp,
                streakDays: streakDays,
                lastActiveDate: lastActiveDate,
                createdAt: createdAt,
                isCurrent: isCurrent,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesLocalTable,
      UserProfilesLocalData,
      $$UserProfilesLocalTableFilterComposer,
      $$UserProfilesLocalTableOrderingComposer,
      $$UserProfilesLocalTableAnnotationComposer,
      $$UserProfilesLocalTableCreateCompanionBuilder,
      $$UserProfilesLocalTableUpdateCompanionBuilder,
      (
        UserProfilesLocalData,
        BaseReferences<
          _$AppDatabase,
          $UserProfilesLocalTable,
          UserProfilesLocalData
        >,
      ),
      UserProfilesLocalData,
      PrefetchHooks Function()
    >;
typedef $$UserAchievementsLocalTableCreateCompanionBuilder =
    UserAchievementsLocalCompanion Function({
      required String id,
      required String userId,
      required String badgeKey,
      required String title,
      required String description,
      Value<String> iconName,
      Value<String> category,
      Value<DateTime?> unlockedAt,
      Value<double> progress,
      Value<bool> isUnlocked,
      Value<int> rowid,
    });
typedef $$UserAchievementsLocalTableUpdateCompanionBuilder =
    UserAchievementsLocalCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> badgeKey,
      Value<String> title,
      Value<String> description,
      Value<String> iconName,
      Value<String> category,
      Value<DateTime?> unlockedAt,
      Value<double> progress,
      Value<bool> isUnlocked,
      Value<int> rowid,
    });

class $$UserAchievementsLocalTableFilterComposer
    extends Composer<_$AppDatabase, $UserAchievementsLocalTable> {
  $$UserAchievementsLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get badgeKey => $composableBuilder(
    column: $table.badgeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isUnlocked => $composableBuilder(
    column: $table.isUnlocked,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserAchievementsLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $UserAchievementsLocalTable> {
  $$UserAchievementsLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get badgeKey => $composableBuilder(
    column: $table.badgeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isUnlocked => $composableBuilder(
    column: $table.isUnlocked,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserAchievementsLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserAchievementsLocalTable> {
  $$UserAchievementsLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get badgeKey =>
      $composableBuilder(column: $table.badgeKey, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<bool> get isUnlocked => $composableBuilder(
    column: $table.isUnlocked,
    builder: (column) => column,
  );
}

class $$UserAchievementsLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserAchievementsLocalTable,
          UserAchievementsLocalData,
          $$UserAchievementsLocalTableFilterComposer,
          $$UserAchievementsLocalTableOrderingComposer,
          $$UserAchievementsLocalTableAnnotationComposer,
          $$UserAchievementsLocalTableCreateCompanionBuilder,
          $$UserAchievementsLocalTableUpdateCompanionBuilder,
          (
            UserAchievementsLocalData,
            BaseReferences<
              _$AppDatabase,
              $UserAchievementsLocalTable,
              UserAchievementsLocalData
            >,
          ),
          UserAchievementsLocalData,
          PrefetchHooks Function()
        > {
  $$UserAchievementsLocalTableTableManager(
    _$AppDatabase db,
    $UserAchievementsLocalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserAchievementsLocalTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$UserAchievementsLocalTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UserAchievementsLocalTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> badgeKey = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> iconName = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<DateTime?> unlockedAt = const Value.absent(),
                Value<double> progress = const Value.absent(),
                Value<bool> isUnlocked = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserAchievementsLocalCompanion(
                id: id,
                userId: userId,
                badgeKey: badgeKey,
                title: title,
                description: description,
                iconName: iconName,
                category: category,
                unlockedAt: unlockedAt,
                progress: progress,
                isUnlocked: isUnlocked,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String badgeKey,
                required String title,
                required String description,
                Value<String> iconName = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<DateTime?> unlockedAt = const Value.absent(),
                Value<double> progress = const Value.absent(),
                Value<bool> isUnlocked = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserAchievementsLocalCompanion.insert(
                id: id,
                userId: userId,
                badgeKey: badgeKey,
                title: title,
                description: description,
                iconName: iconName,
                category: category,
                unlockedAt: unlockedAt,
                progress: progress,
                isUnlocked: isUnlocked,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserAchievementsLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserAchievementsLocalTable,
      UserAchievementsLocalData,
      $$UserAchievementsLocalTableFilterComposer,
      $$UserAchievementsLocalTableOrderingComposer,
      $$UserAchievementsLocalTableAnnotationComposer,
      $$UserAchievementsLocalTableCreateCompanionBuilder,
      $$UserAchievementsLocalTableUpdateCompanionBuilder,
      (
        UserAchievementsLocalData,
        BaseReferences<
          _$AppDatabase,
          $UserAchievementsLocalTable,
          UserAchievementsLocalData
        >,
      ),
      UserAchievementsLocalData,
      PrefetchHooks Function()
    >;
typedef $$UserActivityDailyLocalTableCreateCompanionBuilder =
    UserActivityDailyLocalCompanion Function({
      Value<int> id,
      required String userId,
      required String activityDate,
      Value<int> xpEarned,
      Value<int> minutesSpent,
      Value<int> sessionsCount,
      Value<int> wordsPracticed,
      Value<int> grammarDrillsCount,
      Value<bool> isSynced,
    });
typedef $$UserActivityDailyLocalTableUpdateCompanionBuilder =
    UserActivityDailyLocalCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> activityDate,
      Value<int> xpEarned,
      Value<int> minutesSpent,
      Value<int> sessionsCount,
      Value<int> wordsPracticed,
      Value<int> grammarDrillsCount,
      Value<bool> isSynced,
    });

class $$UserActivityDailyLocalTableFilterComposer
    extends Composer<_$AppDatabase, $UserActivityDailyLocalTable> {
  $$UserActivityDailyLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activityDate => $composableBuilder(
    column: $table.activityDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xpEarned => $composableBuilder(
    column: $table.xpEarned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minutesSpent => $composableBuilder(
    column: $table.minutesSpent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessionsCount => $composableBuilder(
    column: $table.sessionsCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wordsPracticed => $composableBuilder(
    column: $table.wordsPracticed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get grammarDrillsCount => $composableBuilder(
    column: $table.grammarDrillsCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserActivityDailyLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $UserActivityDailyLocalTable> {
  $$UserActivityDailyLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityDate => $composableBuilder(
    column: $table.activityDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xpEarned => $composableBuilder(
    column: $table.xpEarned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minutesSpent => $composableBuilder(
    column: $table.minutesSpent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessionsCount => $composableBuilder(
    column: $table.sessionsCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wordsPracticed => $composableBuilder(
    column: $table.wordsPracticed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grammarDrillsCount => $composableBuilder(
    column: $table.grammarDrillsCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserActivityDailyLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserActivityDailyLocalTable> {
  $$UserActivityDailyLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get activityDate => $composableBuilder(
    column: $table.activityDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get xpEarned =>
      $composableBuilder(column: $table.xpEarned, builder: (column) => column);

  GeneratedColumn<int> get minutesSpent => $composableBuilder(
    column: $table.minutesSpent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sessionsCount => $composableBuilder(
    column: $table.sessionsCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wordsPracticed => $composableBuilder(
    column: $table.wordsPracticed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get grammarDrillsCount => $composableBuilder(
    column: $table.grammarDrillsCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$UserActivityDailyLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserActivityDailyLocalTable,
          UserActivityDailyLocalData,
          $$UserActivityDailyLocalTableFilterComposer,
          $$UserActivityDailyLocalTableOrderingComposer,
          $$UserActivityDailyLocalTableAnnotationComposer,
          $$UserActivityDailyLocalTableCreateCompanionBuilder,
          $$UserActivityDailyLocalTableUpdateCompanionBuilder,
          (
            UserActivityDailyLocalData,
            BaseReferences<
              _$AppDatabase,
              $UserActivityDailyLocalTable,
              UserActivityDailyLocalData
            >,
          ),
          UserActivityDailyLocalData,
          PrefetchHooks Function()
        > {
  $$UserActivityDailyLocalTableTableManager(
    _$AppDatabase db,
    $UserActivityDailyLocalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserActivityDailyLocalTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$UserActivityDailyLocalTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UserActivityDailyLocalTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> activityDate = const Value.absent(),
                Value<int> xpEarned = const Value.absent(),
                Value<int> minutesSpent = const Value.absent(),
                Value<int> sessionsCount = const Value.absent(),
                Value<int> wordsPracticed = const Value.absent(),
                Value<int> grammarDrillsCount = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => UserActivityDailyLocalCompanion(
                id: id,
                userId: userId,
                activityDate: activityDate,
                xpEarned: xpEarned,
                minutesSpent: minutesSpent,
                sessionsCount: sessionsCount,
                wordsPracticed: wordsPracticed,
                grammarDrillsCount: grammarDrillsCount,
                isSynced: isSynced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                required String activityDate,
                Value<int> xpEarned = const Value.absent(),
                Value<int> minutesSpent = const Value.absent(),
                Value<int> sessionsCount = const Value.absent(),
                Value<int> wordsPracticed = const Value.absent(),
                Value<int> grammarDrillsCount = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => UserActivityDailyLocalCompanion.insert(
                id: id,
                userId: userId,
                activityDate: activityDate,
                xpEarned: xpEarned,
                minutesSpent: minutesSpent,
                sessionsCount: sessionsCount,
                wordsPracticed: wordsPracticed,
                grammarDrillsCount: grammarDrillsCount,
                isSynced: isSynced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserActivityDailyLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserActivityDailyLocalTable,
      UserActivityDailyLocalData,
      $$UserActivityDailyLocalTableFilterComposer,
      $$UserActivityDailyLocalTableOrderingComposer,
      $$UserActivityDailyLocalTableAnnotationComposer,
      $$UserActivityDailyLocalTableCreateCompanionBuilder,
      $$UserActivityDailyLocalTableUpdateCompanionBuilder,
      (
        UserActivityDailyLocalData,
        BaseReferences<
          _$AppDatabase,
          $UserActivityDailyLocalTable,
          UserActivityDailyLocalData
        >,
      ),
      UserActivityDailyLocalData,
      PrefetchHooks Function()
    >;
typedef $$UserSettingsLocalTableCreateCompanionBuilder =
    UserSettingsLocalCompanion Function({
      required String userId,
      Value<String> locale,
      Value<int> dailyGoalMinutes,
      Value<String> targetLevel,
      Value<bool> notificationsEnabled,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$UserSettingsLocalTableUpdateCompanionBuilder =
    UserSettingsLocalCompanion Function({
      Value<String> userId,
      Value<String> locale,
      Value<int> dailyGoalMinutes,
      Value<String> targetLevel,
      Value<bool> notificationsEnabled,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$UserSettingsLocalTableFilterComposer
    extends Composer<_$AppDatabase, $UserSettingsLocalTable> {
  $$UserSettingsLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyGoalMinutes => $composableBuilder(
    column: $table.dailyGoalMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetLevel => $composableBuilder(
    column: $table.targetLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserSettingsLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSettingsLocalTable> {
  $$UserSettingsLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyGoalMinutes => $composableBuilder(
    column: $table.dailyGoalMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetLevel => $composableBuilder(
    column: $table.targetLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserSettingsLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSettingsLocalTable> {
  $$UserSettingsLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<int> get dailyGoalMinutes => $composableBuilder(
    column: $table.dailyGoalMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetLevel => $composableBuilder(
    column: $table.targetLevel,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserSettingsLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserSettingsLocalTable,
          UserSettingsLocalData,
          $$UserSettingsLocalTableFilterComposer,
          $$UserSettingsLocalTableOrderingComposer,
          $$UserSettingsLocalTableAnnotationComposer,
          $$UserSettingsLocalTableCreateCompanionBuilder,
          $$UserSettingsLocalTableUpdateCompanionBuilder,
          (
            UserSettingsLocalData,
            BaseReferences<
              _$AppDatabase,
              $UserSettingsLocalTable,
              UserSettingsLocalData
            >,
          ),
          UserSettingsLocalData,
          PrefetchHooks Function()
        > {
  $$UserSettingsLocalTableTableManager(
    _$AppDatabase db,
    $UserSettingsLocalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsLocalTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<int> dailyGoalMinutes = const Value.absent(),
                Value<String> targetLevel = const Value.absent(),
                Value<bool> notificationsEnabled = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserSettingsLocalCompanion(
                userId: userId,
                locale: locale,
                dailyGoalMinutes: dailyGoalMinutes,
                targetLevel: targetLevel,
                notificationsEnabled: notificationsEnabled,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                Value<String> locale = const Value.absent(),
                Value<int> dailyGoalMinutes = const Value.absent(),
                Value<String> targetLevel = const Value.absent(),
                Value<bool> notificationsEnabled = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => UserSettingsLocalCompanion.insert(
                userId: userId,
                locale: locale,
                dailyGoalMinutes: dailyGoalMinutes,
                targetLevel: targetLevel,
                notificationsEnabled: notificationsEnabled,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserSettingsLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserSettingsLocalTable,
      UserSettingsLocalData,
      $$UserSettingsLocalTableFilterComposer,
      $$UserSettingsLocalTableOrderingComposer,
      $$UserSettingsLocalTableAnnotationComposer,
      $$UserSettingsLocalTableCreateCompanionBuilder,
      $$UserSettingsLocalTableUpdateCompanionBuilder,
      (
        UserSettingsLocalData,
        BaseReferences<
          _$AppDatabase,
          $UserSettingsLocalTable,
          UserSettingsLocalData
        >,
      ),
      UserSettingsLocalData,
      PrefetchHooks Function()
    >;
typedef $$VocabularyProgressLocalTableCreateCompanionBuilder =
    VocabularyProgressLocalCompanion Function({
      Value<int> id,
      required String packId,
      required String wordId,
      required String userId,
      Value<int> masteryLevel,
      Value<int> reviewCount,
      Value<double> pronunciationScore,
      Value<bool> isMastered,
      Value<DateTime?> lastReviewedAt,
      Value<bool> isSynced,
    });
typedef $$VocabularyProgressLocalTableUpdateCompanionBuilder =
    VocabularyProgressLocalCompanion Function({
      Value<int> id,
      Value<String> packId,
      Value<String> wordId,
      Value<String> userId,
      Value<int> masteryLevel,
      Value<int> reviewCount,
      Value<double> pronunciationScore,
      Value<bool> isMastered,
      Value<DateTime?> lastReviewedAt,
      Value<bool> isSynced,
    });

class $$VocabularyProgressLocalTableFilterComposer
    extends Composer<_$AppDatabase, $VocabularyProgressLocalTable> {
  $$VocabularyProgressLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packId => $composableBuilder(
    column: $table.packId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wordId => $composableBuilder(
    column: $table.wordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get masteryLevel => $composableBuilder(
    column: $table.masteryLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reviewCount => $composableBuilder(
    column: $table.reviewCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pronunciationScore => $composableBuilder(
    column: $table.pronunciationScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMastered => $composableBuilder(
    column: $table.isMastered,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VocabularyProgressLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $VocabularyProgressLocalTable> {
  $$VocabularyProgressLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packId => $composableBuilder(
    column: $table.packId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wordId => $composableBuilder(
    column: $table.wordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get masteryLevel => $composableBuilder(
    column: $table.masteryLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reviewCount => $composableBuilder(
    column: $table.reviewCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pronunciationScore => $composableBuilder(
    column: $table.pronunciationScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMastered => $composableBuilder(
    column: $table.isMastered,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VocabularyProgressLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $VocabularyProgressLocalTable> {
  $$VocabularyProgressLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get packId =>
      $composableBuilder(column: $table.packId, builder: (column) => column);

  GeneratedColumn<String> get wordId =>
      $composableBuilder(column: $table.wordId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get masteryLevel => $composableBuilder(
    column: $table.masteryLevel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reviewCount => $composableBuilder(
    column: $table.reviewCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get pronunciationScore => $composableBuilder(
    column: $table.pronunciationScore,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isMastered => $composableBuilder(
    column: $table.isMastered,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$VocabularyProgressLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VocabularyProgressLocalTable,
          VocabularyProgressLocalData,
          $$VocabularyProgressLocalTableFilterComposer,
          $$VocabularyProgressLocalTableOrderingComposer,
          $$VocabularyProgressLocalTableAnnotationComposer,
          $$VocabularyProgressLocalTableCreateCompanionBuilder,
          $$VocabularyProgressLocalTableUpdateCompanionBuilder,
          (
            VocabularyProgressLocalData,
            BaseReferences<
              _$AppDatabase,
              $VocabularyProgressLocalTable,
              VocabularyProgressLocalData
            >,
          ),
          VocabularyProgressLocalData,
          PrefetchHooks Function()
        > {
  $$VocabularyProgressLocalTableTableManager(
    _$AppDatabase db,
    $VocabularyProgressLocalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VocabularyProgressLocalTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$VocabularyProgressLocalTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$VocabularyProgressLocalTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> packId = const Value.absent(),
                Value<String> wordId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> masteryLevel = const Value.absent(),
                Value<int> reviewCount = const Value.absent(),
                Value<double> pronunciationScore = const Value.absent(),
                Value<bool> isMastered = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => VocabularyProgressLocalCompanion(
                id: id,
                packId: packId,
                wordId: wordId,
                userId: userId,
                masteryLevel: masteryLevel,
                reviewCount: reviewCount,
                pronunciationScore: pronunciationScore,
                isMastered: isMastered,
                lastReviewedAt: lastReviewedAt,
                isSynced: isSynced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String packId,
                required String wordId,
                required String userId,
                Value<int> masteryLevel = const Value.absent(),
                Value<int> reviewCount = const Value.absent(),
                Value<double> pronunciationScore = const Value.absent(),
                Value<bool> isMastered = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => VocabularyProgressLocalCompanion.insert(
                id: id,
                packId: packId,
                wordId: wordId,
                userId: userId,
                masteryLevel: masteryLevel,
                reviewCount: reviewCount,
                pronunciationScore: pronunciationScore,
                isMastered: isMastered,
                lastReviewedAt: lastReviewedAt,
                isSynced: isSynced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VocabularyProgressLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VocabularyProgressLocalTable,
      VocabularyProgressLocalData,
      $$VocabularyProgressLocalTableFilterComposer,
      $$VocabularyProgressLocalTableOrderingComposer,
      $$VocabularyProgressLocalTableAnnotationComposer,
      $$VocabularyProgressLocalTableCreateCompanionBuilder,
      $$VocabularyProgressLocalTableUpdateCompanionBuilder,
      (
        VocabularyProgressLocalData,
        BaseReferences<
          _$AppDatabase,
          $VocabularyProgressLocalTable,
          VocabularyProgressLocalData
        >,
      ),
      VocabularyProgressLocalData,
      PrefetchHooks Function()
    >;
typedef $$GrammarProgressLocalTableCreateCompanionBuilder =
    GrammarProgressLocalCompanion Function({
      Value<int> id,
      required String unitId,
      required String userId,
      Value<int> attemptsCount,
      Value<double> bestScore,
      Value<double> lastScore,
      Value<bool> isCompleted,
      Value<DateTime?> completedAt,
      Value<bool> isSynced,
    });
typedef $$GrammarProgressLocalTableUpdateCompanionBuilder =
    GrammarProgressLocalCompanion Function({
      Value<int> id,
      Value<String> unitId,
      Value<String> userId,
      Value<int> attemptsCount,
      Value<double> bestScore,
      Value<double> lastScore,
      Value<bool> isCompleted,
      Value<DateTime?> completedAt,
      Value<bool> isSynced,
    });

class $$GrammarProgressLocalTableFilterComposer
    extends Composer<_$AppDatabase, $GrammarProgressLocalTable> {
  $$GrammarProgressLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitId => $composableBuilder(
    column: $table.unitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptsCount => $composableBuilder(
    column: $table.attemptsCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bestScore => $composableBuilder(
    column: $table.bestScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lastScore => $composableBuilder(
    column: $table.lastScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GrammarProgressLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $GrammarProgressLocalTable> {
  $$GrammarProgressLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitId => $composableBuilder(
    column: $table.unitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptsCount => $composableBuilder(
    column: $table.attemptsCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bestScore => $composableBuilder(
    column: $table.bestScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lastScore => $composableBuilder(
    column: $table.lastScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GrammarProgressLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $GrammarProgressLocalTable> {
  $$GrammarProgressLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get unitId =>
      $composableBuilder(column: $table.unitId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get attemptsCount => $composableBuilder(
    column: $table.attemptsCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get bestScore =>
      $composableBuilder(column: $table.bestScore, builder: (column) => column);

  GeneratedColumn<double> get lastScore =>
      $composableBuilder(column: $table.lastScore, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$GrammarProgressLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GrammarProgressLocalTable,
          GrammarProgressLocalData,
          $$GrammarProgressLocalTableFilterComposer,
          $$GrammarProgressLocalTableOrderingComposer,
          $$GrammarProgressLocalTableAnnotationComposer,
          $$GrammarProgressLocalTableCreateCompanionBuilder,
          $$GrammarProgressLocalTableUpdateCompanionBuilder,
          (
            GrammarProgressLocalData,
            BaseReferences<
              _$AppDatabase,
              $GrammarProgressLocalTable,
              GrammarProgressLocalData
            >,
          ),
          GrammarProgressLocalData,
          PrefetchHooks Function()
        > {
  $$GrammarProgressLocalTableTableManager(
    _$AppDatabase db,
    $GrammarProgressLocalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GrammarProgressLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GrammarProgressLocalTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$GrammarProgressLocalTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> unitId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> attemptsCount = const Value.absent(),
                Value<double> bestScore = const Value.absent(),
                Value<double> lastScore = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => GrammarProgressLocalCompanion(
                id: id,
                unitId: unitId,
                userId: userId,
                attemptsCount: attemptsCount,
                bestScore: bestScore,
                lastScore: lastScore,
                isCompleted: isCompleted,
                completedAt: completedAt,
                isSynced: isSynced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String unitId,
                required String userId,
                Value<int> attemptsCount = const Value.absent(),
                Value<double> bestScore = const Value.absent(),
                Value<double> lastScore = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => GrammarProgressLocalCompanion.insert(
                id: id,
                unitId: unitId,
                userId: userId,
                attemptsCount: attemptsCount,
                bestScore: bestScore,
                lastScore: lastScore,
                isCompleted: isCompleted,
                completedAt: completedAt,
                isSynced: isSynced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GrammarProgressLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GrammarProgressLocalTable,
      GrammarProgressLocalData,
      $$GrammarProgressLocalTableFilterComposer,
      $$GrammarProgressLocalTableOrderingComposer,
      $$GrammarProgressLocalTableAnnotationComposer,
      $$GrammarProgressLocalTableCreateCompanionBuilder,
      $$GrammarProgressLocalTableUpdateCompanionBuilder,
      (
        GrammarProgressLocalData,
        BaseReferences<
          _$AppDatabase,
          $GrammarProgressLocalTable,
          GrammarProgressLocalData
        >,
      ),
      GrammarProgressLocalData,
      PrefetchHooks Function()
    >;
typedef $$OfflineEventsLocalTableCreateCompanionBuilder =
    OfflineEventsLocalCompanion Function({
      Value<int> id,
      required String eventType,
      required String payloadJson,
      required String userId,
      required DateTime createdAt,
      Value<bool> isSynced,
    });
typedef $$OfflineEventsLocalTableUpdateCompanionBuilder =
    OfflineEventsLocalCompanion Function({
      Value<int> id,
      Value<String> eventType,
      Value<String> payloadJson,
      Value<String> userId,
      Value<DateTime> createdAt,
      Value<bool> isSynced,
    });

class $$OfflineEventsLocalTableFilterComposer
    extends Composer<_$AppDatabase, $OfflineEventsLocalTable> {
  $$OfflineEventsLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OfflineEventsLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $OfflineEventsLocalTable> {
  $$OfflineEventsLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OfflineEventsLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $OfflineEventsLocalTable> {
  $$OfflineEventsLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$OfflineEventsLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OfflineEventsLocalTable,
          OfflineEventsLocalData,
          $$OfflineEventsLocalTableFilterComposer,
          $$OfflineEventsLocalTableOrderingComposer,
          $$OfflineEventsLocalTableAnnotationComposer,
          $$OfflineEventsLocalTableCreateCompanionBuilder,
          $$OfflineEventsLocalTableUpdateCompanionBuilder,
          (
            OfflineEventsLocalData,
            BaseReferences<
              _$AppDatabase,
              $OfflineEventsLocalTable,
              OfflineEventsLocalData
            >,
          ),
          OfflineEventsLocalData,
          PrefetchHooks Function()
        > {
  $$OfflineEventsLocalTableTableManager(
    _$AppDatabase db,
    $OfflineEventsLocalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OfflineEventsLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OfflineEventsLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OfflineEventsLocalTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => OfflineEventsLocalCompanion(
                id: id,
                eventType: eventType,
                payloadJson: payloadJson,
                userId: userId,
                createdAt: createdAt,
                isSynced: isSynced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String eventType,
                required String payloadJson,
                required String userId,
                required DateTime createdAt,
                Value<bool> isSynced = const Value.absent(),
              }) => OfflineEventsLocalCompanion.insert(
                id: id,
                eventType: eventType,
                payloadJson: payloadJson,
                userId: userId,
                createdAt: createdAt,
                isSynced: isSynced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OfflineEventsLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OfflineEventsLocalTable,
      OfflineEventsLocalData,
      $$OfflineEventsLocalTableFilterComposer,
      $$OfflineEventsLocalTableOrderingComposer,
      $$OfflineEventsLocalTableAnnotationComposer,
      $$OfflineEventsLocalTableCreateCompanionBuilder,
      $$OfflineEventsLocalTableUpdateCompanionBuilder,
      (
        OfflineEventsLocalData,
        BaseReferences<
          _$AppDatabase,
          $OfflineEventsLocalTable,
          OfflineEventsLocalData
        >,
      ),
      OfflineEventsLocalData,
      PrefetchHooks Function()
    >;
typedef $$UnitProgressLocalTableCreateCompanionBuilder =
    UnitProgressLocalCompanion Function({
      Value<int> id,
      required String userId,
      required String track,
      required String objectiveId,
      Value<double> masteryScore,
      Value<int> attempts,
      Value<String> state,
      Value<DateTime?> lastPracticedAt,
      Value<int> streak,
      Value<bool> isSynced,
    });
typedef $$UnitProgressLocalTableUpdateCompanionBuilder =
    UnitProgressLocalCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> track,
      Value<String> objectiveId,
      Value<double> masteryScore,
      Value<int> attempts,
      Value<String> state,
      Value<DateTime?> lastPracticedAt,
      Value<int> streak,
      Value<bool> isSynced,
    });

class $$UnitProgressLocalTableFilterComposer
    extends Composer<_$AppDatabase, $UnitProgressLocalTable> {
  $$UnitProgressLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get track => $composableBuilder(
    column: $table.track,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get objectiveId => $composableBuilder(
    column: $table.objectiveId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get masteryScore => $composableBuilder(
    column: $table.masteryScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPracticedAt => $composableBuilder(
    column: $table.lastPracticedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get streak => $composableBuilder(
    column: $table.streak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UnitProgressLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $UnitProgressLocalTable> {
  $$UnitProgressLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get track => $composableBuilder(
    column: $table.track,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get objectiveId => $composableBuilder(
    column: $table.objectiveId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get masteryScore => $composableBuilder(
    column: $table.masteryScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPracticedAt => $composableBuilder(
    column: $table.lastPracticedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get streak => $composableBuilder(
    column: $table.streak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UnitProgressLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $UnitProgressLocalTable> {
  $$UnitProgressLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get track =>
      $composableBuilder(column: $table.track, builder: (column) => column);

  GeneratedColumn<String> get objectiveId => $composableBuilder(
    column: $table.objectiveId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get masteryScore => $composableBuilder(
    column: $table.masteryScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPracticedAt => $composableBuilder(
    column: $table.lastPracticedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get streak =>
      $composableBuilder(column: $table.streak, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$UnitProgressLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UnitProgressLocalTable,
          UnitProgressLocalData,
          $$UnitProgressLocalTableFilterComposer,
          $$UnitProgressLocalTableOrderingComposer,
          $$UnitProgressLocalTableAnnotationComposer,
          $$UnitProgressLocalTableCreateCompanionBuilder,
          $$UnitProgressLocalTableUpdateCompanionBuilder,
          (
            UnitProgressLocalData,
            BaseReferences<
              _$AppDatabase,
              $UnitProgressLocalTable,
              UnitProgressLocalData
            >,
          ),
          UnitProgressLocalData,
          PrefetchHooks Function()
        > {
  $$UnitProgressLocalTableTableManager(
    _$AppDatabase db,
    $UnitProgressLocalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UnitProgressLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UnitProgressLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UnitProgressLocalTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> track = const Value.absent(),
                Value<String> objectiveId = const Value.absent(),
                Value<double> masteryScore = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<DateTime?> lastPracticedAt = const Value.absent(),
                Value<int> streak = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => UnitProgressLocalCompanion(
                id: id,
                userId: userId,
                track: track,
                objectiveId: objectiveId,
                masteryScore: masteryScore,
                attempts: attempts,
                state: state,
                lastPracticedAt: lastPracticedAt,
                streak: streak,
                isSynced: isSynced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                required String track,
                required String objectiveId,
                Value<double> masteryScore = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<DateTime?> lastPracticedAt = const Value.absent(),
                Value<int> streak = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => UnitProgressLocalCompanion.insert(
                id: id,
                userId: userId,
                track: track,
                objectiveId: objectiveId,
                masteryScore: masteryScore,
                attempts: attempts,
                state: state,
                lastPracticedAt: lastPracticedAt,
                streak: streak,
                isSynced: isSynced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UnitProgressLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UnitProgressLocalTable,
      UnitProgressLocalData,
      $$UnitProgressLocalTableFilterComposer,
      $$UnitProgressLocalTableOrderingComposer,
      $$UnitProgressLocalTableAnnotationComposer,
      $$UnitProgressLocalTableCreateCompanionBuilder,
      $$UnitProgressLocalTableUpdateCompanionBuilder,
      (
        UnitProgressLocalData,
        BaseReferences<
          _$AppDatabase,
          $UnitProgressLocalTable,
          UnitProgressLocalData
        >,
      ),
      UnitProgressLocalData,
      PrefetchHooks Function()
    >;
typedef $$PracticeAttemptsLocalTableCreateCompanionBuilder =
    PracticeAttemptsLocalCompanion Function({
      Value<int> id,
      required String userId,
      required String objectiveId,
      Value<String?> scenario,
      Value<String?> difficultyBand,
      required String track,
      Value<double> score,
      Value<int> durationSeconds,
      Value<int> mistakes,
      Value<int> repeatedItems,
      Value<int> fsrsGenerated,
      required DateTime createdAt,
      Value<bool> isSynced,
    });
typedef $$PracticeAttemptsLocalTableUpdateCompanionBuilder =
    PracticeAttemptsLocalCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> objectiveId,
      Value<String?> scenario,
      Value<String?> difficultyBand,
      Value<String> track,
      Value<double> score,
      Value<int> durationSeconds,
      Value<int> mistakes,
      Value<int> repeatedItems,
      Value<int> fsrsGenerated,
      Value<DateTime> createdAt,
      Value<bool> isSynced,
    });

class $$PracticeAttemptsLocalTableFilterComposer
    extends Composer<_$AppDatabase, $PracticeAttemptsLocalTable> {
  $$PracticeAttemptsLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get objectiveId => $composableBuilder(
    column: $table.objectiveId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scenario => $composableBuilder(
    column: $table.scenario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get difficultyBand => $composableBuilder(
    column: $table.difficultyBand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get track => $composableBuilder(
    column: $table.track,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mistakes => $composableBuilder(
    column: $table.mistakes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repeatedItems => $composableBuilder(
    column: $table.repeatedItems,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fsrsGenerated => $composableBuilder(
    column: $table.fsrsGenerated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PracticeAttemptsLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $PracticeAttemptsLocalTable> {
  $$PracticeAttemptsLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get objectiveId => $composableBuilder(
    column: $table.objectiveId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scenario => $composableBuilder(
    column: $table.scenario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get difficultyBand => $composableBuilder(
    column: $table.difficultyBand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get track => $composableBuilder(
    column: $table.track,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mistakes => $composableBuilder(
    column: $table.mistakes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repeatedItems => $composableBuilder(
    column: $table.repeatedItems,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fsrsGenerated => $composableBuilder(
    column: $table.fsrsGenerated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PracticeAttemptsLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $PracticeAttemptsLocalTable> {
  $$PracticeAttemptsLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get objectiveId => $composableBuilder(
    column: $table.objectiveId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scenario =>
      $composableBuilder(column: $table.scenario, builder: (column) => column);

  GeneratedColumn<String> get difficultyBand => $composableBuilder(
    column: $table.difficultyBand,
    builder: (column) => column,
  );

  GeneratedColumn<String> get track =>
      $composableBuilder(column: $table.track, builder: (column) => column);

  GeneratedColumn<double> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get mistakes =>
      $composableBuilder(column: $table.mistakes, builder: (column) => column);

  GeneratedColumn<int> get repeatedItems => $composableBuilder(
    column: $table.repeatedItems,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fsrsGenerated => $composableBuilder(
    column: $table.fsrsGenerated,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$PracticeAttemptsLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PracticeAttemptsLocalTable,
          PracticeAttemptsLocalData,
          $$PracticeAttemptsLocalTableFilterComposer,
          $$PracticeAttemptsLocalTableOrderingComposer,
          $$PracticeAttemptsLocalTableAnnotationComposer,
          $$PracticeAttemptsLocalTableCreateCompanionBuilder,
          $$PracticeAttemptsLocalTableUpdateCompanionBuilder,
          (
            PracticeAttemptsLocalData,
            BaseReferences<
              _$AppDatabase,
              $PracticeAttemptsLocalTable,
              PracticeAttemptsLocalData
            >,
          ),
          PracticeAttemptsLocalData,
          PrefetchHooks Function()
        > {
  $$PracticeAttemptsLocalTableTableManager(
    _$AppDatabase db,
    $PracticeAttemptsLocalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PracticeAttemptsLocalTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PracticeAttemptsLocalTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PracticeAttemptsLocalTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> objectiveId = const Value.absent(),
                Value<String?> scenario = const Value.absent(),
                Value<String?> difficultyBand = const Value.absent(),
                Value<String> track = const Value.absent(),
                Value<double> score = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<int> mistakes = const Value.absent(),
                Value<int> repeatedItems = const Value.absent(),
                Value<int> fsrsGenerated = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => PracticeAttemptsLocalCompanion(
                id: id,
                userId: userId,
                objectiveId: objectiveId,
                scenario: scenario,
                difficultyBand: difficultyBand,
                track: track,
                score: score,
                durationSeconds: durationSeconds,
                mistakes: mistakes,
                repeatedItems: repeatedItems,
                fsrsGenerated: fsrsGenerated,
                createdAt: createdAt,
                isSynced: isSynced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                required String objectiveId,
                Value<String?> scenario = const Value.absent(),
                Value<String?> difficultyBand = const Value.absent(),
                required String track,
                Value<double> score = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<int> mistakes = const Value.absent(),
                Value<int> repeatedItems = const Value.absent(),
                Value<int> fsrsGenerated = const Value.absent(),
                required DateTime createdAt,
                Value<bool> isSynced = const Value.absent(),
              }) => PracticeAttemptsLocalCompanion.insert(
                id: id,
                userId: userId,
                objectiveId: objectiveId,
                scenario: scenario,
                difficultyBand: difficultyBand,
                track: track,
                score: score,
                durationSeconds: durationSeconds,
                mistakes: mistakes,
                repeatedItems: repeatedItems,
                fsrsGenerated: fsrsGenerated,
                createdAt: createdAt,
                isSynced: isSynced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PracticeAttemptsLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PracticeAttemptsLocalTable,
      PracticeAttemptsLocalData,
      $$PracticeAttemptsLocalTableFilterComposer,
      $$PracticeAttemptsLocalTableOrderingComposer,
      $$PracticeAttemptsLocalTableAnnotationComposer,
      $$PracticeAttemptsLocalTableCreateCompanionBuilder,
      $$PracticeAttemptsLocalTableUpdateCompanionBuilder,
      (
        PracticeAttemptsLocalData,
        BaseReferences<
          _$AppDatabase,
          $PracticeAttemptsLocalTable,
          PracticeAttemptsLocalData
        >,
      ),
      PracticeAttemptsLocalData,
      PrefetchHooks Function()
    >;
typedef $$UserPhonemeProgressLocalTableCreateCompanionBuilder =
    UserPhonemeProgressLocalCompanion Function({
      Value<int> id,
      required String userId,
      required String phoneme,
      Value<int> attempts,
      Value<int> successes,
      Value<double> meanGop,
      Value<double> lastGop,
      Value<double> recencyWeightedGop,
      Value<double> wilsonLowerBound,
      Value<String> confusionMapJson,
      Value<DateTime?> lastPracticedAt,
      Value<bool> isSynced,
    });
typedef $$UserPhonemeProgressLocalTableUpdateCompanionBuilder =
    UserPhonemeProgressLocalCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> phoneme,
      Value<int> attempts,
      Value<int> successes,
      Value<double> meanGop,
      Value<double> lastGop,
      Value<double> recencyWeightedGop,
      Value<double> wilsonLowerBound,
      Value<String> confusionMapJson,
      Value<DateTime?> lastPracticedAt,
      Value<bool> isSynced,
    });

class $$UserPhonemeProgressLocalTableFilterComposer
    extends Composer<_$AppDatabase, $UserPhonemeProgressLocalTable> {
  $$UserPhonemeProgressLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneme => $composableBuilder(
    column: $table.phoneme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get successes => $composableBuilder(
    column: $table.successes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get meanGop => $composableBuilder(
    column: $table.meanGop,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lastGop => $composableBuilder(
    column: $table.lastGop,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get recencyWeightedGop => $composableBuilder(
    column: $table.recencyWeightedGop,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get wilsonLowerBound => $composableBuilder(
    column: $table.wilsonLowerBound,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get confusionMapJson => $composableBuilder(
    column: $table.confusionMapJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPracticedAt => $composableBuilder(
    column: $table.lastPracticedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserPhonemeProgressLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $UserPhonemeProgressLocalTable> {
  $$UserPhonemeProgressLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneme => $composableBuilder(
    column: $table.phoneme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get successes => $composableBuilder(
    column: $table.successes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get meanGop => $composableBuilder(
    column: $table.meanGop,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lastGop => $composableBuilder(
    column: $table.lastGop,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get recencyWeightedGop => $composableBuilder(
    column: $table.recencyWeightedGop,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get wilsonLowerBound => $composableBuilder(
    column: $table.wilsonLowerBound,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confusionMapJson => $composableBuilder(
    column: $table.confusionMapJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPracticedAt => $composableBuilder(
    column: $table.lastPracticedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserPhonemeProgressLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserPhonemeProgressLocalTable> {
  $$UserPhonemeProgressLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get phoneme =>
      $composableBuilder(column: $table.phoneme, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<int> get successes =>
      $composableBuilder(column: $table.successes, builder: (column) => column);

  GeneratedColumn<double> get meanGop =>
      $composableBuilder(column: $table.meanGop, builder: (column) => column);

  GeneratedColumn<double> get lastGop =>
      $composableBuilder(column: $table.lastGop, builder: (column) => column);

  GeneratedColumn<double> get recencyWeightedGop => $composableBuilder(
    column: $table.recencyWeightedGop,
    builder: (column) => column,
  );

  GeneratedColumn<double> get wilsonLowerBound => $composableBuilder(
    column: $table.wilsonLowerBound,
    builder: (column) => column,
  );

  GeneratedColumn<String> get confusionMapJson => $composableBuilder(
    column: $table.confusionMapJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastPracticedAt => $composableBuilder(
    column: $table.lastPracticedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$UserPhonemeProgressLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserPhonemeProgressLocalTable,
          UserPhonemeProgressLocalData,
          $$UserPhonemeProgressLocalTableFilterComposer,
          $$UserPhonemeProgressLocalTableOrderingComposer,
          $$UserPhonemeProgressLocalTableAnnotationComposer,
          $$UserPhonemeProgressLocalTableCreateCompanionBuilder,
          $$UserPhonemeProgressLocalTableUpdateCompanionBuilder,
          (
            UserPhonemeProgressLocalData,
            BaseReferences<
              _$AppDatabase,
              $UserPhonemeProgressLocalTable,
              UserPhonemeProgressLocalData
            >,
          ),
          UserPhonemeProgressLocalData,
          PrefetchHooks Function()
        > {
  $$UserPhonemeProgressLocalTableTableManager(
    _$AppDatabase db,
    $UserPhonemeProgressLocalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserPhonemeProgressLocalTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$UserPhonemeProgressLocalTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UserPhonemeProgressLocalTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> phoneme = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int> successes = const Value.absent(),
                Value<double> meanGop = const Value.absent(),
                Value<double> lastGop = const Value.absent(),
                Value<double> recencyWeightedGop = const Value.absent(),
                Value<double> wilsonLowerBound = const Value.absent(),
                Value<String> confusionMapJson = const Value.absent(),
                Value<DateTime?> lastPracticedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => UserPhonemeProgressLocalCompanion(
                id: id,
                userId: userId,
                phoneme: phoneme,
                attempts: attempts,
                successes: successes,
                meanGop: meanGop,
                lastGop: lastGop,
                recencyWeightedGop: recencyWeightedGop,
                wilsonLowerBound: wilsonLowerBound,
                confusionMapJson: confusionMapJson,
                lastPracticedAt: lastPracticedAt,
                isSynced: isSynced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                required String phoneme,
                Value<int> attempts = const Value.absent(),
                Value<int> successes = const Value.absent(),
                Value<double> meanGop = const Value.absent(),
                Value<double> lastGop = const Value.absent(),
                Value<double> recencyWeightedGop = const Value.absent(),
                Value<double> wilsonLowerBound = const Value.absent(),
                Value<String> confusionMapJson = const Value.absent(),
                Value<DateTime?> lastPracticedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => UserPhonemeProgressLocalCompanion.insert(
                id: id,
                userId: userId,
                phoneme: phoneme,
                attempts: attempts,
                successes: successes,
                meanGop: meanGop,
                lastGop: lastGop,
                recencyWeightedGop: recencyWeightedGop,
                wilsonLowerBound: wilsonLowerBound,
                confusionMapJson: confusionMapJson,
                lastPracticedAt: lastPracticedAt,
                isSynced: isSynced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserPhonemeProgressLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserPhonemeProgressLocalTable,
      UserPhonemeProgressLocalData,
      $$UserPhonemeProgressLocalTableFilterComposer,
      $$UserPhonemeProgressLocalTableOrderingComposer,
      $$UserPhonemeProgressLocalTableAnnotationComposer,
      $$UserPhonemeProgressLocalTableCreateCompanionBuilder,
      $$UserPhonemeProgressLocalTableUpdateCompanionBuilder,
      (
        UserPhonemeProgressLocalData,
        BaseReferences<
          _$AppDatabase,
          $UserPhonemeProgressLocalTable,
          UserPhonemeProgressLocalData
        >,
      ),
      UserPhonemeProgressLocalData,
      PrefetchHooks Function()
    >;
typedef $$UserAudioBaselinesLocalTableCreateCompanionBuilder =
    UserAudioBaselinesLocalCompanion Function({
      required String id,
      required String userId,
      required String targetType,
      required String targetId,
      required String baselineAudioPath,
      Value<double> baselineScore,
      Value<double> baselineGop,
      required DateTime baselineCreatedAt,
      Value<String?> latestAudioPath,
      Value<double?> latestScore,
      Value<double?> latestGop,
      Value<DateTime?> latestUpdatedAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$UserAudioBaselinesLocalTableUpdateCompanionBuilder =
    UserAudioBaselinesLocalCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> targetType,
      Value<String> targetId,
      Value<String> baselineAudioPath,
      Value<double> baselineScore,
      Value<double> baselineGop,
      Value<DateTime> baselineCreatedAt,
      Value<String?> latestAudioPath,
      Value<double?> latestScore,
      Value<double?> latestGop,
      Value<DateTime?> latestUpdatedAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });

class $$UserAudioBaselinesLocalTableFilterComposer
    extends Composer<_$AppDatabase, $UserAudioBaselinesLocalTable> {
  $$UserAudioBaselinesLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baselineAudioPath => $composableBuilder(
    column: $table.baselineAudioPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get baselineScore => $composableBuilder(
    column: $table.baselineScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get baselineGop => $composableBuilder(
    column: $table.baselineGop,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get baselineCreatedAt => $composableBuilder(
    column: $table.baselineCreatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get latestAudioPath => $composableBuilder(
    column: $table.latestAudioPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latestScore => $composableBuilder(
    column: $table.latestScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latestGop => $composableBuilder(
    column: $table.latestGop,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get latestUpdatedAt => $composableBuilder(
    column: $table.latestUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserAudioBaselinesLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $UserAudioBaselinesLocalTable> {
  $$UserAudioBaselinesLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baselineAudioPath => $composableBuilder(
    column: $table.baselineAudioPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get baselineScore => $composableBuilder(
    column: $table.baselineScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get baselineGop => $composableBuilder(
    column: $table.baselineGop,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get baselineCreatedAt => $composableBuilder(
    column: $table.baselineCreatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get latestAudioPath => $composableBuilder(
    column: $table.latestAudioPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latestScore => $composableBuilder(
    column: $table.latestScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latestGop => $composableBuilder(
    column: $table.latestGop,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get latestUpdatedAt => $composableBuilder(
    column: $table.latestUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserAudioBaselinesLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserAudioBaselinesLocalTable> {
  $$UserAudioBaselinesLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<String> get baselineAudioPath => $composableBuilder(
    column: $table.baselineAudioPath,
    builder: (column) => column,
  );

  GeneratedColumn<double> get baselineScore => $composableBuilder(
    column: $table.baselineScore,
    builder: (column) => column,
  );

  GeneratedColumn<double> get baselineGop => $composableBuilder(
    column: $table.baselineGop,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get baselineCreatedAt => $composableBuilder(
    column: $table.baselineCreatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get latestAudioPath => $composableBuilder(
    column: $table.latestAudioPath,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latestScore => $composableBuilder(
    column: $table.latestScore,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latestGop =>
      $composableBuilder(column: $table.latestGop, builder: (column) => column);

  GeneratedColumn<DateTime> get latestUpdatedAt => $composableBuilder(
    column: $table.latestUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$UserAudioBaselinesLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserAudioBaselinesLocalTable,
          UserAudioBaselinesLocalData,
          $$UserAudioBaselinesLocalTableFilterComposer,
          $$UserAudioBaselinesLocalTableOrderingComposer,
          $$UserAudioBaselinesLocalTableAnnotationComposer,
          $$UserAudioBaselinesLocalTableCreateCompanionBuilder,
          $$UserAudioBaselinesLocalTableUpdateCompanionBuilder,
          (
            UserAudioBaselinesLocalData,
            BaseReferences<
              _$AppDatabase,
              $UserAudioBaselinesLocalTable,
              UserAudioBaselinesLocalData
            >,
          ),
          UserAudioBaselinesLocalData,
          PrefetchHooks Function()
        > {
  $$UserAudioBaselinesLocalTableTableManager(
    _$AppDatabase db,
    $UserAudioBaselinesLocalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserAudioBaselinesLocalTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$UserAudioBaselinesLocalTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UserAudioBaselinesLocalTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> targetType = const Value.absent(),
                Value<String> targetId = const Value.absent(),
                Value<String> baselineAudioPath = const Value.absent(),
                Value<double> baselineScore = const Value.absent(),
                Value<double> baselineGop = const Value.absent(),
                Value<DateTime> baselineCreatedAt = const Value.absent(),
                Value<String?> latestAudioPath = const Value.absent(),
                Value<double?> latestScore = const Value.absent(),
                Value<double?> latestGop = const Value.absent(),
                Value<DateTime?> latestUpdatedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserAudioBaselinesLocalCompanion(
                id: id,
                userId: userId,
                targetType: targetType,
                targetId: targetId,
                baselineAudioPath: baselineAudioPath,
                baselineScore: baselineScore,
                baselineGop: baselineGop,
                baselineCreatedAt: baselineCreatedAt,
                latestAudioPath: latestAudioPath,
                latestScore: latestScore,
                latestGop: latestGop,
                latestUpdatedAt: latestUpdatedAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String targetType,
                required String targetId,
                required String baselineAudioPath,
                Value<double> baselineScore = const Value.absent(),
                Value<double> baselineGop = const Value.absent(),
                required DateTime baselineCreatedAt,
                Value<String?> latestAudioPath = const Value.absent(),
                Value<double?> latestScore = const Value.absent(),
                Value<double?> latestGop = const Value.absent(),
                Value<DateTime?> latestUpdatedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserAudioBaselinesLocalCompanion.insert(
                id: id,
                userId: userId,
                targetType: targetType,
                targetId: targetId,
                baselineAudioPath: baselineAudioPath,
                baselineScore: baselineScore,
                baselineGop: baselineGop,
                baselineCreatedAt: baselineCreatedAt,
                latestAudioPath: latestAudioPath,
                latestScore: latestScore,
                latestGop: latestGop,
                latestUpdatedAt: latestUpdatedAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserAudioBaselinesLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserAudioBaselinesLocalTable,
      UserAudioBaselinesLocalData,
      $$UserAudioBaselinesLocalTableFilterComposer,
      $$UserAudioBaselinesLocalTableOrderingComposer,
      $$UserAudioBaselinesLocalTableAnnotationComposer,
      $$UserAudioBaselinesLocalTableCreateCompanionBuilder,
      $$UserAudioBaselinesLocalTableUpdateCompanionBuilder,
      (
        UserAudioBaselinesLocalData,
        BaseReferences<
          _$AppDatabase,
          $UserAudioBaselinesLocalTable,
          UserAudioBaselinesLocalData
        >,
      ),
      UserAudioBaselinesLocalData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SessionsLocalTableTableManager get sessionsLocal =>
      $$SessionsLocalTableTableManager(_db, _db.sessionsLocal);
  $$TurnsLocalTableTableManager get turnsLocal =>
      $$TurnsLocalTableTableManager(_db, _db.turnsLocal);
  $$ReviewLogsLocalTableTableManager get reviewLogsLocal =>
      $$ReviewLogsLocalTableTableManager(_db, _db.reviewLogsLocal);
  $$CardsLocalTableTableManager get cardsLocal =>
      $$CardsLocalTableTableManager(_db, _db.cardsLocal);
  $$QueueItemsTableTableManager get queueItems =>
      $$QueueItemsTableTableManager(_db, _db.queueItems);
  $$JournalEntriesTableTableManager get journalEntries =>
      $$JournalEntriesTableTableManager(_db, _db.journalEntries);
  $$UserMilestonesLocalTableTableManager get userMilestonesLocal =>
      $$UserMilestonesLocalTableTableManager(_db, _db.userMilestonesLocal);
  $$ResourcesLocalTableTableManager get resourcesLocal =>
      $$ResourcesLocalTableTableManager(_db, _db.resourcesLocal);
  $$ResourceCollectionsLocalTableTableManager get resourceCollectionsLocal =>
      $$ResourceCollectionsLocalTableTableManager(
        _db,
        _db.resourceCollectionsLocal,
      );
  $$UnitResourceLinksLocalTableTableManager get unitResourceLinksLocal =>
      $$UnitResourceLinksLocalTableTableManager(
        _db,
        _db.unitResourceLinksLocal,
      );
  $$ResourceUsageLogsLocalTableTableManager get resourceUsageLogsLocal =>
      $$ResourceUsageLogsLocalTableTableManager(
        _db,
        _db.resourceUsageLogsLocal,
      );
  $$UserProfilesLocalTableTableManager get userProfilesLocal =>
      $$UserProfilesLocalTableTableManager(_db, _db.userProfilesLocal);
  $$UserAchievementsLocalTableTableManager get userAchievementsLocal =>
      $$UserAchievementsLocalTableTableManager(_db, _db.userAchievementsLocal);
  $$UserActivityDailyLocalTableTableManager get userActivityDailyLocal =>
      $$UserActivityDailyLocalTableTableManager(
        _db,
        _db.userActivityDailyLocal,
      );
  $$UserSettingsLocalTableTableManager get userSettingsLocal =>
      $$UserSettingsLocalTableTableManager(_db, _db.userSettingsLocal);
  $$VocabularyProgressLocalTableTableManager get vocabularyProgressLocal =>
      $$VocabularyProgressLocalTableTableManager(
        _db,
        _db.vocabularyProgressLocal,
      );
  $$GrammarProgressLocalTableTableManager get grammarProgressLocal =>
      $$GrammarProgressLocalTableTableManager(_db, _db.grammarProgressLocal);
  $$OfflineEventsLocalTableTableManager get offlineEventsLocal =>
      $$OfflineEventsLocalTableTableManager(_db, _db.offlineEventsLocal);
  $$UnitProgressLocalTableTableManager get unitProgressLocal =>
      $$UnitProgressLocalTableTableManager(_db, _db.unitProgressLocal);
  $$PracticeAttemptsLocalTableTableManager get practiceAttemptsLocal =>
      $$PracticeAttemptsLocalTableTableManager(_db, _db.practiceAttemptsLocal);
  $$UserPhonemeProgressLocalTableTableManager get userPhonemeProgressLocal =>
      $$UserPhonemeProgressLocalTableTableManager(
        _db,
        _db.userPhonemeProgressLocal,
      );
  $$UserAudioBaselinesLocalTableTableManager get userAudioBaselinesLocal =>
      $$UserAudioBaselinesLocalTableTableManager(
        _db,
        _db.userAudioBaselinesLocal,
      );
}
