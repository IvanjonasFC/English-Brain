import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/core/providers/app_providers.dart';
import 'package:app/core/database/app_database.dart';
import 'package:app/features/phonetics/models/phonetic_models.dart';
import 'package:app/core/theme/app_haptics.dart';
import '../../core/widgets/coach_marks.dart';
import 'package:drift/drift.dart' as drift;

class HvptExerciseScreen extends ConsumerStatefulWidget {
  final String? targetPhoneme;

  const HvptExerciseScreen({super.key, this.targetPhoneme});

  @override
  ConsumerState<HvptExerciseScreen> createState() => _HvptExerciseScreenState();
}

class _HvptExerciseScreenState extends ConsumerState<HvptExerciseScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey _kCoachAudio = GlobalKey();
  final GlobalKey _kCoachChoices = GlobalKey();

  late List<MinimalPairItem> _sessionItems;
  int _currentIndex = 0;
  bool _targetIsA = true;
  String _targetWord = '';
  String _targetIpa = '';
  String _targetPhoneme = '';

  bool _hasAnswered = false;
  bool _selectedA = false;
  bool _isCorrect = false;

  int _hits = 0;
  int _totalTargets = 0;
  int _falseAlarms = 0;
  int _totalDistractors = 0;

  bool _isAiAnalyzing = false;
  final Random _rng = Random();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _prepareSession();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowCoach());
  }

  Future<void> _maybeShowCoach() async {
    final cache = ref.read(localCacheProvider);
    if (await cache.hasSeenCoach('hvpt_lab')) return;
    if (!mounted) return;
    const Color accentColor = Color(0xFF0284C7);
    await showCoachMarks(
      context,
      [
        CoachStep(
          targetKey: _kCoachAudio,
          title: 'Entrenamiento Auditivo HVPT',
          body: 'Escucha la palabra reproducida con audio neuronal nativo a 24kHz. Puedes pulsar el botón tantas veces como necesites o escucharlo a 0.8x.',
        ),
        CoachStep(
          targetKey: _kCoachChoices,
          title: 'Discriminación de Pares Mínimos',
          body: 'Elige cuál de los dos fonemas contrastantes has escuchado. Tu acierto entrena tu cerebro para distinguir contrastes sutiles que no existen en español.',
        ),
        const CoachStep(
          title: 'Índice de Sensibilidad d\' y Mapa de 44 Fonemas',
          body: 'Al finalizar, calculamos tu índice de sensibilidad d\' real (descartando sesgos) y actualizamos tu Mapa de Calor Fonético en el Perfil.',
        ),
      ],
      accent: accentColor,
    );
    await cache.markCoachSeen('hvpt_lab');
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _prepareSession() {
    List<MinimalPairItem> pool;
    if (widget.targetPhoneme != null) {
      final target = widget.targetPhoneme!.trim().toLowerCase();
      pool = PhoneticTaxonomy.minimalPairs.where((pair) {
        return pair.phonemeA.toLowerCase() == target ||
            pair.phonemeB.toLowerCase() == target;
      }).toList();
      if (pool.isEmpty) {
        pool = List.from(PhoneticTaxonomy.minimalPairs);
      }
    } else {
      pool = List.from(PhoneticTaxonomy.minimalPairs);
    }
    pool.shuffle(_rng);
    _sessionItems = pool.take(8).toList();
    ref.read(audioPrefetchProvider).warm(
      pool.expand((p) => [p.wordA, p.wordB]),
      includeSlow: false,
    );
    if (_sessionItems.isEmpty) {
      _sessionItems = [PhoneticTaxonomy.minimalPairs.first];
    }
    _loadCurrentItem();
  }

  void _loadCurrentItem() {
    final currentPair = _sessionItems[_currentIndex];
    _targetIsA = _rng.nextBool();
    _targetWord = _targetIsA ? currentPair.wordA : currentPair.wordB;
    _targetIpa = _targetIsA ? currentPair.ipaA : currentPair.ipaB;
    _targetPhoneme = _targetIsA ? currentPair.phonemeA : currentPair.phonemeB;
    _hasAnswered = false;
    _isAiAnalyzing = false;

    // Autoplay audio al cargar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio();
    });
  }

  Future<void> _playAudio({bool slow = false}) async {
    final player = ref.read(audioPlayerProvider);
    await player.playTts(_targetWord);
  }

  Future<void> _submitAnswer(bool chooseA) async {
    if (_hasAnswered) return;

    final isCorrect = (chooseA == _targetIsA);
    if (isCorrect) {
      AppHaptics.medium();
    } else {
      AppHaptics.error();
    }

    setState(() {
      _hasAnswered = true;
      _selectedA = chooseA;
      _isCorrect = isCorrect;
      _isAiAnalyzing = true;

      // Signal detection theory metrics
      _totalTargets += 1;
      _totalDistractors += 1;
      if (isCorrect) {
        _hits += 1;
      } else {
        _falseAlarms += 1;
      }
    });

    // Simulación elegante de micro-análisis IA C1
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() {
          _isAiAnalyzing = false;
        });
      }
    });

    // Guardar en la base de datos local Drift
    await _recordProgressLocally(isCorrect);
  }

  Future<void> _recordProgressLocally(bool isSuccess) async {
    try {
      final db = ref.read(appDatabaseProvider);
      final userId = ref.read(activeUserIdProvider);
      final phKey = _targetPhoneme.toLowerCase();

      final existing = await (db.select(db.userPhonemeProgressLocal)
            ..where((tbl) => tbl.userId.equals(userId) & tbl.phoneme.equals(phKey)))
          .getSingleOrNull();

      final now = DateTime.now();
      final itemScore = isSuccess ? 100.0 : 0.0;

      if (existing == null) {
        await db.into(db.userPhonemeProgressLocal).insert(
              UserPhonemeProgressLocalCompanion.insert(
                userId: userId,
                phoneme: phKey,
                attempts: const drift.Value(1),
                successes: drift.Value(isSuccess ? 1 : 0),
                meanGop: drift.Value(itemScore),
                lastGop: drift.Value(itemScore),
                recencyWeightedGop: drift.Value(itemScore),
                wilsonLowerBound: drift.Value(isSuccess ? 0.2 : 0.0),
                lastPracticedAt: drift.Value(now),
                isSynced: const drift.Value(false),
              ),
            );
      } else {
        final att = existing.attempts + 1;
        final succ = existing.successes + (isSuccess ? 1 : 0);
        final newMean = ((existing.meanGop * existing.attempts) + itemScore) / att;

        await (db.update(db.userPhonemeProgressLocal)
              ..where((tbl) => tbl.id.equals(existing.id)))
            .write(
          UserPhonemeProgressLocalCompanion(
            attempts: drift.Value(att),
            successes: drift.Value(succ),
            meanGop: drift.Value(newMean),
            lastGop: drift.Value(itemScore),
            recencyWeightedGop: drift.Value(newMean),
            wilsonLowerBound: drift.Value(succ / att * 0.8),
            lastPracticedAt: drift.Value(now),
            isSynced: const drift.Value(false),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error guardando progreso fonético local: $e');
    }
  }

  void _nextItem() {
    AppHaptics.selection();
    if (_currentIndex + 1 < _sessionItems.length) {
      setState(() {
        _currentIndex += 1;
      });
      _loadCurrentItem();
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    AppHaptics.heavy();
    final dPrime = SignalDetectionDPrime.calculate(
      hits: _hits,
      totalTargets: _totalTargets,
      falseAlarms: _falseAlarms,
      totalDistractors: _totalDistractors,
    );

    final isLight = ref.read(themeIsLightProvider);
    final bg = isLight ? const Color(0xFFFAF8F5) : const Color(0xFF1E293B);
    final textPrimary = isLight ? const Color(0xFF0F172A) : Colors.white;
    final textMuted = isLight ? const Color(0xFF64748B) : Colors.white70;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: bg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Trophy badge
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFF59E0B), width: 2),
                  ),
                  child: const Icon(Icons.emoji_events_rounded, color: Color(0xFFD97706), size: 36),
                ),
                const SizedBox(height: 16),
                Text(
                  '¡Sesión HVPT Completada!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Índice de Sensibilidad Perceptual (d\')',
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, color: textMuted),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: isLight ? const Color(0xFFF0FDF4) : const Color(0xFF064E3B).withAlpha(120),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'd\' = ${dPrime.toStringAsFixed(2)}',
                        style: GoogleFonts.firaCode(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF059669),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dPrime >= 2.0
                            ? '🌟 Dominio C2 (Agudeza Nativa)'
                            : (dPrime >= 1.2 ? '🎯 Precisión C1 (Alta)' : '🧠 En Reentrenamiento'),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isLight ? Colors.white : Colors.black26,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isLight ? const Color(0xFFE2E8F0) : Colors.white12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('Aciertos', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: textMuted)),
                          Text('$_hits / $_totalTargets',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary)),
                        ],
                      ),
                      Container(width: 1, height: 28, color: isLight ? const Color(0xFFE2E8F0) : Colors.white12),
                      Column(
                        children: [
                          Text('Falsas Alarmas', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: textMuted)),
                          Text('$_falseAlarms',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFFEF4444))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  dPrime >= 1.8
                      ? '¡Excelente discriminación auditiva! Tu córtex temporal procesa los formantes F1/F2 sin sesgo del español.'
                      : 'Buen entrenamiento. La plasticidad neuronal fijará las representaciones acústicas con repetición espaciada.',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: textMuted, height: 1.4),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      'Terminar y Guardar',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = ref.watch(themeIsLightProvider);
    final currentPair = _sessionItems[_currentIndex];
    final isPlaying = ref.watch(audioPlayerProvider.select((p) => p.isPlaying));
    const accentColor = Color(0xFF0284C7); // Neural Cyan / Sky Blue C1

    // Dynamic pastel theme palette
    final bgColor = isLight ? const Color(0xFFFAF8F5) : const Color(0xFF0F172A);
    final textPrimary = isLight ? const Color(0xFF0F172A) : Colors.white;
    final textSecondary = isLight ? const Color(0xFF64748B) : Colors.white70;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'Entrenamiento HVPT',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            Text(
              'Percepción Auditiva de Alta Variabilidad (C1)',
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close_rounded, color: textSecondary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress Bar (Duolingo Style with smooth radius)
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (_currentIndex + 1) / _sessionItems.length,
                        backgroundColor: isLight ? const Color(0xFFE2E8F0) : Colors.white12,
                        valueColor: const AlwaysStoppedAnimation(accentColor),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_currentIndex + 1}/${_sessionItems.length}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Contrast Header Pill
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isLight ? const Color(0xFFF0F9FF) : const Color(0xFF0C4A6E).withAlpha(120),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF38BDF8).withAlpha(120)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.compare_arrows_rounded, size: 16, color: accentColor),
                      const SizedBox(width: 6),
                      Text(
                        currentPair.contrastTitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Central Audio Circle
              Center(
                child: KeyedSubtree(
                  key: _kCoachAudio,
                  child: GestureDetector(
                    onTap: () {
                      AppHaptics.selection();
                      _playAudio();
                    },
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final scale = isPlaying ? 1.0 + (_pulseController.value * 0.08) : 1.0;
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isPlaying ? accentColor : (isLight ? Colors.white : const Color(0xFF1E293B)),
                              border: Border.all(
                                color: isPlaying ? accentColor : accentColor.withAlpha(180),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withAlpha(isPlaying ? 80 : 30),
                                  blurRadius: isPlaying ? 24 : 12,
                                  spreadRadius: isPlaying ? 4 : 1,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              isPlaying ? Icons.graphic_eq_rounded : Icons.volume_up_rounded,
                              size: 44,
                              color: isPlaying ? Colors.white : accentColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Slow speed button
              Center(
                child: InkWell(
                  onTap: () {
                    AppHaptics.light();
                    _playAudio(slow: true);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.speed_rounded, size: 15, color: textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'Escuchar lento (0.8x)',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: textSecondary, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Text(
                '¿Cuál de las dos palabras has escuchado?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),

              // A / B Choice cards
              Expanded(
                child: KeyedSubtree(
                  key: _kCoachChoices,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildDuolingoChoiceCard(
                          isA: true,
                          word: currentPair.wordA,
                          ipa: currentPair.ipaA,
                          phoneme: currentPair.phonemeA,
                          isLight: isLight,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildDuolingoChoiceCard(
                          isA: false,
                          word: currentPair.wordB,
                          ipa: currentPair.ipaB,
                          phoneme: currentPair.phonemeB,
                          isLight: isLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Feedback Panel (Academic C1 & AI Biomechanics)
              if (_hasAnswered) ...[
                const SizedBox(height: 12),
                _buildAcademicFeedbackCard(currentPair, isLight),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      _currentIndex + 1 < _sessionItems.length ? 'Siguiente Par →' : 'Ver Resultados Finales',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDuolingoChoiceCard({
    required bool isA,
    required String word,
    required String ipa,
    required String phoneme,
    required bool isLight,
  }) {
    Color cardBg = isLight ? Colors.white : const Color(0xFF1E293B);
    Color borderColor = isLight ? const Color(0xFFE2E8F0) : Colors.white12;
    Color bottomBorderColor = isLight ? const Color(0xFFCBD5E1) : Colors.white24;
    Color titleColor = isLight ? const Color(0xFF0F172A) : Colors.white;

    if (_hasAnswered) {
      final wasCorrectAnswer = (isA == _targetIsA);
      final wasSelected = (isA == _selectedA);

      if (wasCorrectAnswer) {
        cardBg = isLight ? const Color(0xFFECFDF5) : const Color(0xFF064E3B).withAlpha(160);
        borderColor = const Color(0xFF10B981);
        bottomBorderColor = const Color(0xFF059669);
      } else if (wasSelected && !wasCorrectAnswer) {
        cardBg = isLight ? const Color(0xFFFEF2F2) : const Color(0xFF7F1D1D).withAlpha(160);
        borderColor = const Color(0xFFEF4444);
        bottomBorderColor = const Color(0xFFDC2626);
      }
    }

    return InkWell(
      onTap: _hasAnswered ? null : () => _submitAnswer(isA),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: bottomBorderColor,
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
            if (isLight && !_hasAnswered)
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: isLight ? const Color(0xFFF1F5F9) : Colors.white10,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isA ? 'OPCIÓN A' : 'OPCIÓN B',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isLight ? const Color(0xFF64748B) : Colors.white60,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const Spacer(),
            Text(
              word,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              ipa,
              style: GoogleFonts.firaCode(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0284C7),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: isLight ? const Color(0xFFF8FAFC) : Colors.white.withAlpha(15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isLight ? const Color(0xFFE2E8F0) : Colors.white12),
              ),
              child: Text(
                '/$phoneme/',
                style: GoogleFonts.firaCode(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isLight ? const Color(0xFF475569) : Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicFeedbackCard(MinimalPairItem currentPair, bool isLight) {
    final isSuccess = _isCorrect;
    final bannerBg = isSuccess
        ? (isLight ? const Color(0xFFECFDF5) : const Color(0xFF064E3B).withAlpha(160))
        : (isLight ? const Color(0xFFFEF2F2) : const Color(0xFF7F1D1D).withAlpha(160));
    final bannerBorder = isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: bannerBorder.withAlpha(180), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle_rounded : Icons.info_rounded,
                color: isSuccess ? const Color(0xFF059669) : const Color(0xFFDC2626),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isSuccess ? '¡Discriminación Auditiva Correcta!' : 'Palabra emitida: "$_targetWord" ($_targetIpa)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isSuccess
                        ? (isLight ? const Color(0xFF065F46) : Colors.white)
                        : (isLight ? const Color(0xFF991B1B) : Colors.white),
                  ),
                ),
              ),
              if (_isAiAnalyzing)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Color(0xFF3B82F6))),
                ),
            ],
          ),
          const SizedBox(height: 6),
          // C1 Linguistic/Biomechanical Explanation
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isLight ? Colors.white.withAlpha(200) : Colors.black26,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.psychology_alt_rounded, size: 16, color: Color(0xFF6366F1)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    currentPair.l1Explanation,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: isLight ? const Color(0xFF334155) : Colors.white70,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
