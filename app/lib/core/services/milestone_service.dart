import 'package:drift/drift.dart';
import '../database/app_database.dart';

class MilestoneService {
  final AppDatabase _db;

  MilestoneService(this._db);

  static const defaultMilestones = [
    {
      'id': 'first_session',
      'title': 'Primera Sesión',
      'description': 'Completaste tu primera sesión de simulación hablada.',
    },
    {
      'id': 'ten_sessions',
      'title': '10 Sesiones',
      'description': 'Constancia demostrada: 10 entrevistas técnicas completadas.',
    },
    {
      'id': 'hundred_cards',
      'title': '100 Tarjetas Repasadas',
      'description': '100 repasos espaciados FSRS consolidados en memoria.',
    },
    {
      'id': 'streak_7',
      'title': 'Racha de 7 Días',
      'description': 'Una semana ininterrumpida de práctica activa.',
    },
    {
      'id': 'streak_30',
      'title': 'Racha de 30 Días',
      'description': 'Un mes entero de disciplina y práctica continua.',
    },
    {
      'id': 'ef_set_score',
      'title': 'Certificación EF SET',
      'description': 'Puntaje de prueba estandarizada registrado manualmente.',
    },
  ];

  Future<void> initDefaults() async {
    for (final m in defaultMilestones) {
      final exists = await (_db.select(_db.userMilestonesLocal)
            ..where((tbl) => tbl.id.equals(m['id']!)))
          .getSingleOrNull();

      if (exists == null) {
        await _db.into(_db.userMilestonesLocal).insert(
              UserMilestonesLocalCompanion.insert(
                id: m['id']!,
                title: m['title']!,
                description: m['description']!,
                achieved: const Value(false),
              ),
            );
      }
    }
  }

  Future<List<UserMilestonesLocalData>> getAllMilestones() async {
    await initDefaults();
    return _db.select(_db.userMilestonesLocal).get();
  }

  Future<void> evaluateMilestones({
    required int totalSessions,
    required int totalCardReviews,
    required int streakDays,
  }) async {
    await initDefaults();
    final now = DateTime.now();

    if (totalSessions >= 1) {
      await _unlockMilestone('first_session', now);
    }
    if (totalSessions >= 10) {
      await _unlockMilestone('ten_sessions', now);
    }
    if (totalCardReviews >= 100) {
      await _unlockMilestone('hundred_cards', now);
    }
    if (streakDays >= 7) {
      await _unlockMilestone('streak_7', now);
    }
    if (streakDays >= 30) {
      await _unlockMilestone('streak_30', now);
    }
  }

  /// Reconcilia los hitos con el estado REAL local (recuentos de la base de
  /// datos), sin depender del backend. Se llama tras cualquier actividad y al
  /// abrir Progreso, de modo que los hitos siempre reflejan lo que has hecho.
  ///
  /// "Sesiones" cuenta solo las simulaciones habladas (entradas de diario de
  /// entrevista: su sessionId NO empieza por 'act_', que es el prefijo de las
  /// demas actividades). Las tarjetas cuentan los repasos FSRS reales.
  Future<void> reconcileFromLocal({
    required int streakDays,
    int extraSessions = 0,
    int extraCards = 0,
  }) async {
    await initDefaults();
    final journals = await _db.select(_db.journalEntries).get();
    final spokenSessions =
        journals.where((j) => !j.sessionId.startsWith('act_')).length;
    final totalReviews = (await _db.select(_db.reviewLogsLocal).get()).length;
    // Usamos el mayor entre el recuento local y el acumulado del backend, para
    // que los hitos sean coherentes con las metricas que se muestran arriba.
    final sessions = spokenSessions > extraSessions ? spokenSessions : extraSessions;
    final cards = totalReviews > extraCards ? totalReviews : extraCards;
    await evaluateMilestones(
      totalSessions: sessions,
      totalCardReviews: cards,
      streakDays: streakDays,
    );
  }

  Future<void> _unlockMilestone(String id, DateTime date) async {
    final item = await (_db.select(_db.userMilestonesLocal)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    if (item != null && !item.achieved) {
      await (_db.update(_db.userMilestonesLocal)..where((tbl) => tbl.id.equals(id))).write(
        UserMilestonesLocalCompanion(
          achieved: const Value(true),
          achievedAt: Value(date),
        ),
      );
    }
  }

  Future<void> setEfSetScore(String scoreString) async {
    await initDefaults();
    await (_db.update(_db.userMilestonesLocal)..where((tbl) => tbl.id.equals('ef_set_score'))).write(
      UserMilestonesLocalCompanion(
        achieved: const Value(true),
        achievedAt: Value(DateTime.now()),
        value: Value(scoreString),
      ),
    );
  }
}
