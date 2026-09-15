import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import 'package:app/core/database/app_database.dart';
import 'package:app/core/network/api_client.dart';
import 'package:app/core/storage/secure_storage_service.dart';
import 'package:app/core/storage/local_cache_service.dart';
import 'package:app/core/pedagogy/contracts.dart';
import 'package:app/core/pedagogy/taxonomy.dart';
import 'package:app/core/pedagogy/review_ingestion.dart';

/// Spy ApiClient: records the best-effort online push and can simulate an
/// offline/server-unreachable failure without any real network.
class _SpyApiClient extends ApiClient {
  _SpyApiClient({this.failOnline = false})
      : super(
          secureStorage: SecureStorageService(),
          cacheService: LocalCacheService(),
        );

  final bool failOnline;
  final List<Map<String, dynamic>> pushed = [];

  @override
  Future<void> ingestReviewCard(Map<String, dynamic> cardJson) async {
    if (failOnline) throw Exception('offline / server unreachable');
    pushed.add(cardJson);
  }
}

const _vocabMiss = ReviewItem(
  front: 'bottleneck',
  back: 'cuello de botella',
  sourceType: ReviewSource.vocabulary,
  sourceRef: 'bottleneck',
  itemType: ReviewItemType.wordMeaning,
  unitOrPackId: 'vocab_devops_b2',
  skill: Track.vocabulary,
);

const _interviewMiss = ReviewItem(
  front: 'Walk me through a critical production bug',
  back: 'STAR opener you struggled with',
  sourceType: ReviewSource.interviewMistake,
  sourceRef: 'q101',
  itemType: ReviewItemType.interviewOpener,
  unitOrPackId: 'interview_debugging_walkthrough',
  skill: Track.speaking,
);

const _grammarMiss = ReviewItem(
  front: 'If the node ___ (fail), traffic reroutes.',
  back: 'fails (zero conditional)',
  sourceType: ReviewSource.grammar,
  sourceRef: 'hypothetical_troubleshooting',
  itemType: ReviewItemType.sentenceCorrection,
  unitOrPackId: 'grammar_conditionals_b2',
  skill: Track.grammar,
);

void main() {
  // ApiClient/plugin services only need the binding to exist to be constructed.
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    // Owner of the transversal deck (satisfies the FK if enabled).
    await db.into(db.userProfilesLocal).insert(
          UserProfilesLocalCompanion.insert(
            id: 'user-ivan',
            displayName: 'Iván',
            createdAt: DateTime.now(),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  test('offline-first: a failed online push still persists one local FSRS card per item',
      () async {
    final api = _SpyApiClient(failOnline: true);
    final service = ReviewIngestionService(db, api);

    final count = await service.ingest('user-ivan', const [_vocabMiss, _interviewMiss]);

    expect(count, 2, reason: 'ingest reports every item processed even when offline');
    expect(api.pushed, isEmpty, reason: 'the online push threw, so nothing was pushed');

    final cards = await db.select(db.cardsLocal).get();
    expect(cards.length, 2, reason: 'local cards are written regardless of the network');
    expect(cards.map((c) => c.front), containsAll(<String>['bottleneck', _interviewMiss.front]));
  });

  test('a persisted card maps the review item onto a brand-new FSRS card', () async {
    final api = _SpyApiClient();
    final service = ReviewIngestionService(db, api);

    await service.ingest('user-ivan', const [_vocabMiss]);

    final card = (await db.select(db.cardsLocal).get()).single;
    expect(card.front, _vocabMiss.front);
    expect(card.back, _vocabMiss.back);
    // Fresh FSRS state.
    expect(card.state, 0, reason: 'New');
    expect(card.stability, 0.0);
    expect(card.reps, 0);
    expect(card.lapses, 0);
    // Provenance carried through so the deck stays cross-tab traceable.
    expect(card.sourceType, _vocabMiss.sourceType.id);
    expect(card.itemType, _vocabMiss.itemType.id);
    expect(card.unitOrPackId, _vocabMiss.unitOrPackId);
    expect(card.skill, _vocabMiss.skill.id);
    expect(card.userId, 'user-ivan');
    // Local-only cards use negative ids so they never collide with server ids.
    expect(card.id, lessThan(0));

    // Online path is best-effort but does fire when reachable.
    expect(api.pushed, hasLength(1));
    expect(api.pushed.single['front'], _vocabMiss.front);
    expect(api.pushed.single['source_type'], _vocabMiss.sourceType.id);
  });

  test('mistakes from every tab land in the same transversal deck for the user', () async {
    final api = _SpyApiClient();
    final service = ReviewIngestionService(db, api);

    await service.ingest('user-ivan', const [_vocabMiss, _interviewMiss, _grammarMiss]);

    final cards = await db.select(db.cardsLocal).get();
    expect(cards, hasLength(3));
    expect(cards.every((c) => c.userId == 'user-ivan'), isTrue);
    // One shared deck fed by three different sources.
    expect(
      cards.map((c) => c.sourceType).toSet(),
      {
        ReviewSource.vocabulary.id,
        ReviewSource.interviewMistake.id,
        ReviewSource.grammar.id,
      },
    );
    // No id collisions across a single batch.
    expect(cards.map((c) => c.id).toSet(), hasLength(3));
  });

  test('empty batch is a no-op', () async {
    final api = _SpyApiClient();
    final service = ReviewIngestionService(db, api);

    final count = await service.ingest('user-ivan', const []);

    expect(count, 0);
    expect(await db.select(db.cardsLocal).get(), isEmpty);
    expect(api.pushed, isEmpty);
  });
}
