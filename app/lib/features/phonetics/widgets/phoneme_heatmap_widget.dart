import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/database/app_database.dart';
import 'package:app/core/providers/app_providers.dart';
import 'package:app/features/phonetics/models/phonetic_models.dart';
import 'package:app/features/phonetics/hvpt_exercise_screen.dart';
import 'package:app/core/theme/app_haptics.dart';

final userPhonemeProgressStreamProvider =
    StreamProvider.autoDispose<List<UserPhonemeProgressLocalData>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final userId = ref.watch(activeUserIdProvider);
  return (db.select(db.userPhonemeProgressLocal)
        ..where((tbl) => tbl.userId.equals(userId)))
      .watch();
});

class PhonemeHeatmapWidget extends ConsumerWidget {
  final bool compact;

  const PhonemeHeatmapWidget({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(userPhonemeProgressStreamProvider);
    final isLight = ref.watch(themeIsLightProvider);

    return progressAsync.when(
      data: (records) {
        final progressMap = <String, UserPhonemeProgressLocalData>{};
        for (final r in records) {
          progressMap[r.phoneme.toLowerCase()] = r;
        }

        if (compact) {
          return _buildCompactCard(context, progressMap, isLight);
        }

        return _buildFullHeatmapColumn(context, progressMap, isLight);
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, st) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Error cargando mapa fonético: $e',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildCompactCard(
    BuildContext context,
    Map<String, UserPhonemeProgressLocalData> progressMap,
    bool isLight,
  ) {
    final titleColor = isLight ? const Color(0xFF0F172A) : Colors.white;
    final subtitleColor = isLight ? const Color(0xFF64748B) : Colors.white60;

    int masteredCount = 0;
    int practicedCount = 0;
    for (final p in PhoneticTaxonomy.all44Phonemes) {
      final prog = progressMap[p.symbol.toLowerCase()] ?? progressMap[p.arpaKey.toLowerCase()];
      if (prog != null && prog.attempts > 0) {
        practicedCount++;
        if (prog.attempts >= 8 && prog.recencyWeightedGop >= 80) {
          masteredCount++;
        }
      }
    }

    final double progressRatio = practicedCount > 0 ? (masteredCount / 44.0) : 0.0;

    // Métricas por grupo
    final shortVowels = PhoneticTaxonomy.all44Phonemes.where((p) => p.category == PhonemeCategory.shortVowel);
    final shortMastered = shortVowels.where((p) {
      final rec = progressMap[p.symbol.toLowerCase()] ?? progressMap[p.arpaKey.toLowerCase()];
      return rec != null && rec.attempts >= 8 && rec.recencyWeightedGop >= 80;
    }).length;

    final longVowels = PhoneticTaxonomy.all44Phonemes.where((p) => p.category == PhonemeCategory.longVowel);
    final longMastered = longVowels.where((p) {
      final rec = progressMap[p.symbol.toLowerCase()] ?? progressMap[p.arpaKey.toLowerCase()];
      return rec != null && rec.attempts >= 8 && rec.recencyWeightedGop >= 80;
    }).length;

    final diphthongs = PhoneticTaxonomy.all44Phonemes.where((p) => p.category == PhonemeCategory.diphthong);
    final diphMastered = diphthongs.where((p) {
      final rec = progressMap[p.symbol.toLowerCase()] ?? progressMap[p.arpaKey.toLowerCase()];
      return rec != null && rec.attempts >= 8 && rec.recencyWeightedGop >= 80;
    }).length;

    final consonants = PhoneticTaxonomy.all44Phonemes.where((p) =>
        p.category != PhonemeCategory.shortVowel &&
        p.category != PhonemeCategory.longVowel &&
        p.category != PhonemeCategory.diphthong);
    final consMastered = consonants.where((p) {
      final rec = progressMap[p.symbol.toLowerCase()] ?? progressMap[p.arpaKey.toLowerCase()];
      return rec != null && rec.attempts >= 8 && rec.recencyWeightedGop >= 80;
    }).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: isLight ? 0.12 : 0.25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: isLight ? 0.25 : 0.5),
                ),
              ),
              child: const Icon(
                Icons.graphic_eq_rounded,
                color: AppTheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mapa Fonético (44 Sonidos)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Evaluación continua GOP con intervalo Wilson 95%',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: isLight ? 0.12 : 0.22),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '$masteredCount/44',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Barra de progreso general
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progressRatio.clamp(0.02, 1.0),
            minHeight: 7,
            backgroundColor: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
        ),
        const SizedBox(height: 12),

        // Chips compactos de categorías
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildMiniCategoryChip('Vocales Cortas', '$shortMastered/${shortVowels.length}', const Color(0xFFD97706), const Color(0xFFFFFBEB), const Color(0xFF1F1A10), isLight),
            _buildMiniCategoryChip('Vocales Largas', '$longMastered/${longVowels.length}', const Color(0xFF059669), const Color(0xFFECFDF5), const Color(0xFF0B241B), isLight),
            _buildMiniCategoryChip('Diptongos', '$diphMastered/${diphthongs.length}', const Color(0xFF7C3AED), const Color(0xFFF5F3FF), const Color(0xFF1E1438), isLight),
            _buildMiniCategoryChip('Consonantes', '$consMastered/${consonants.length}', const Color(0xFF0284C7), const Color(0xFFF0F9FF), const Color(0xFF0C243B), isLight),
          ],
        ),
        const SizedBox(height: 16),

        // Botón para expandir en Modal Bottom Sheet interactivo
        SizedBox(
          width: double.infinity,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                AppHaptics.light();
                _showFullHeatmapBottomSheet(context, progressMap, isLight);
              },
              child: Ink(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isLight
                        ? [const Color(0xFFF8FAFC), const Color(0xFFEEF2F6)]
                        : [const Color(0xFF1E293B), const Color(0xFF0F172A)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isLight ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.explore_rounded, size: 18, color: AppTheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Explorar Mapa de 44 Fonemas',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isLight ? const Color(0xFF1E293B) : Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded, size: 16, color: AppTheme.primary),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniCategoryChip(
    String label,
    String count,
    Color accent,
    Color lightBg,
    Color darkBg,
    bool isLight,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isLight ? lightBg : darkBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: accent.withValues(alpha: isLight ? 0.3 : 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isLight ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
            ),
          ),
          Text(
            count,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }

  void _showFullHeatmapBottomSheet(
    BuildContext context,
    Map<String, UserPhonemeProgressLocalData> progressMap,
    bool isLight,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isLight ? Colors.white : const Color(0xFF13131A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (scrollCtx, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isLight ? Colors.black12 : Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildFullHeatmapColumn(sheetCtx, progressMap, isLight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullHeatmapColumn(
    BuildContext context,
    Map<String, UserPhonemeProgressLocalData> progressMap,
    bool isLight,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, isLight),
        const SizedBox(height: 16),
        _buildCategoryCard(
          context: context,
          isLight: isLight,
          title: 'Vocales Cortas',
          subtitle: 'Sonidos breves y relajados sin tensión laríngea',
          icon: Icons.grain_rounded,
          category: PhonemeCategory.shortVowel,
          pastelLightBg: const Color(0xFFFFFBEB),
          pastelDarkBg: const Color(0xFF1F1A10),
          accentColor: const Color(0xFFD97706),
          progressMap: progressMap,
        ),
        const SizedBox(height: 14),
        _buildCategoryCard(
          context: context,
          isLight: isLight,
          title: 'Vocales Largas',
          subtitle: 'Sonidos tensos y prolongados con alargamiento (ː)',
          icon: Icons.graphic_eq_rounded,
          category: PhonemeCategory.longVowel,
          pastelLightBg: const Color(0xFFECFDF5),
          pastelDarkBg: const Color(0xFF0B241B),
          accentColor: const Color(0xFF059669),
          progressMap: progressMap,
        ),
        const SizedBox(height: 14),
        _buildCategoryCard(
          context: context,
          isLight: isLight,
          title: 'Diptongos',
          subtitle: 'Desplazamiento armónico continuo entre dos vocales',
          icon: Icons.waves_rounded,
          category: PhonemeCategory.diphthong,
          pastelLightBg: const Color(0xFFF5F3FF),
          pastelDarkBg: const Color(0xFF1E1438),
          accentColor: const Color(0xFF7C3AED),
          progressMap: progressMap,
        ),
        const SizedBox(height: 14),
        _buildCategoryCard(
          context: context,
          isLight: isLight,
          title: 'Consonantes Oclusivas (Plosives)',
          subtitle: 'Bloqueo y liberación repentina de aire (/p, b, t, d, k, g/)',
          icon: Icons.flash_on_rounded,
          category: PhonemeCategory.plosive,
          pastelLightBg: const Color(0xFFF0F9FF),
          pastelDarkBg: const Color(0xFF0C243B),
          accentColor: const Color(0xFF0284C7),
          progressMap: progressMap,
        ),
        const SizedBox(height: 14),
        _buildCategoryCard(
          context: context,
          isLight: isLight,
          title: 'Consonantes Fricativas',
          subtitle: 'Fricción constante de aire (/f, v, θ, ð, s, z, ʃ, ʒ, h/)',
          icon: Icons.air_rounded,
          category: PhonemeCategory.fricative,
          pastelLightBg: const Color(0xFFFFF1F2),
          pastelDarkBg: const Color(0xFF2C1019),
          accentColor: const Color(0xFFE11D48),
          progressMap: progressMap,
        ),
        const SizedBox(height: 14),
        _buildCategoryCard(
          context: context,
          isLight: isLight,
          title: 'Africadas y Nasales',
          subtitle: 'Cierre oclusivo con fricción o resonancia nasal (/tʃ, dʒ, m, n, ŋ/)',
          icon: Icons.record_voice_over_rounded,
          categories: [PhonemeCategory.affricate, PhonemeCategory.nasal],
          pastelLightBg: const Color(0xFFEEF2FF),
          pastelDarkBg: const Color(0xFF141938),
          accentColor: const Color(0xFF4F46E5),
          progressMap: progressMap,
        ),
        const SizedBox(height: 14),
        _buildCategoryCard(
          context: context,
          isLight: isLight,
          title: 'Aproximantes y Líquidas',
          subtitle: 'Articuladores cercanos sin crear turbulencia (/l, r, w, j/)',
          icon: Icons.all_inclusive_rounded,
          category: PhonemeCategory.approximant,
          pastelLightBg: const Color(0xFFF0FDFA),
          pastelDarkBg: const Color(0xFF0A2624),
          accentColor: const Color(0xFF0D9488),
          progressMap: progressMap,
        ),
        const SizedBox(height: 18),
        _buildLegend(context, isLight),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isLight) {
    final titleColor = isLight ? const Color(0xFF0F172A) : Colors.white;
    final subtitleColor = isLight ? const Color(0xFF64748B) : Colors.white60;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: isLight ? 0.12 : 0.25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: isLight ? 0.25 : 0.5),
            ),
          ),
          child: const Icon(
            Icons.graphic_eq_rounded,
            color: AppTheme.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mapa Fonético (44 Sonidos)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Evaluación continua GOP con intervalo Wilson 95%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required BuildContext context,
    required bool isLight,
    required String title,
    required String subtitle,
    required IconData icon,
    PhonemeCategory? category,
    List<PhonemeCategory>? categories,
    required Color pastelLightBg,
    required Color pastelDarkBg,
    required Color accentColor,
    required Map<String, UserPhonemeProgressLocalData> progressMap,
  }) {
    final phonemes = PhoneticTaxonomy.all44Phonemes.where((p) {
      if (category != null) return p.category == category;
      if (categories != null) return categories.contains(p.category);
      return false;
    }).toList();

    int masteredCount = 0;
    for (final p in phonemes) {
      final rec = progressMap[p.symbol.toLowerCase()] ??
          progressMap[p.arpaKey.toLowerCase()];
      if (rec != null && rec.attempts >= 8 && rec.recencyWeightedGop >= 80) {
        masteredCount++;
      }
    }

    final cardBg = isLight ? pastelLightBg : pastelDarkBg;
    final cardBorder = isLight
        ? accentColor.withValues(alpha: 0.22)
        : accentColor.withValues(alpha: 0.35);
    final titleColor = isLight ? const Color(0xFF0F172A) : Colors.white;
    final subtitleColor = isLight ? const Color(0xFF64748B) : Colors.white60;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: isLight
                ? accentColor.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: accentColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isLight
                      ? accentColor.withValues(alpha: 0.12)
                      : accentColor.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '$masteredCount/${phonemes.length}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: subtitleColor,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: phonemes.map((p) {
              final rec = progressMap[p.symbol.toLowerCase()] ??
                  progressMap[p.arpaKey.toLowerCase()];
              return _buildPhonemeTile(context, isLight, p, rec, accentColor);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPhonemeTile(
    BuildContext context,
    bool isLight,
    PhonemeInfo info,
    UserPhonemeProgressLocalData? record,
    Color categoryAccent,
  ) {
    final attempts = record?.attempts ?? 0;
    final isCollecting = attempts < 8; // Muestra honesta de datos
    final score = record != null && attempts > 0
        ? (record.recencyWeightedGop > 0
            ? record.recencyWeightedGop
            : record.meanGop)
        : 0.0;

    Color tileBg;
    Color borderCol;
    Color textCol;
    Color counterCol;

    if (isCollecting) {
      tileBg = isLight ? Colors.white : const Color(0xFF1E293B);
      borderCol = isLight ? const Color(0xFFE2E8F0) : const Color(0xFF334155);
      textCol = isLight ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
      counterCol = isLight ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
    } else if (score >= 80) {
      tileBg = isLight ? const Color(0xFFD1FAE5) : const Color(0xFF064E3B);
      borderCol = const Color(0xFF10B981);
      textCol = isLight ? const Color(0xFF065F46) : const Color(0xFFA7F3D0);
      counterCol = textCol;
    } else if (score >= 60) {
      tileBg = isLight ? const Color(0xFFFEF3C7) : const Color(0xFF78350F);
      borderCol = const Color(0xFFF59E0B);
      textCol = isLight ? const Color(0xFF92400E) : const Color(0xFFFDE68A);
      counterCol = textCol;
    } else {
      tileBg = isLight ? const Color(0xFFFFE4E6) : const Color(0xFF7F1D1D);
      borderCol = const Color(0xFFEF4444);
      textCol = isLight ? const Color(0xFF9F1239) : const Color(0xFFFECDD3);
      counterCol = textCol;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AppHaptics.light();
          _showPhonemeDetailSheet(context, isLight, info, record);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minWidth: 56, minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: tileBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderCol, width: isCollecting ? 1 : 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isLight ? 0.04 : 0.15),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '/${info.symbol}/',
                style: GoogleFonts.firaCode(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: textCol,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isCollecting ? '$attempts/8' : '${score.round()}%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight:
                      isCollecting ? FontWeight.w500 : FontWeight.bold,
                  color: counterCol,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPhonemeDetailSheet(
    BuildContext context,
    bool isLight,
    PhonemeInfo info,
    UserPhonemeProgressLocalData? record,
  ) {
    final attempts = record?.attempts ?? 0;
    final successes = record?.successes ?? 0;
    final score = record?.recencyWeightedGop ?? 0.0;
    final wilson = record?.wilsonLowerBound ?? 0.0;

    final sheetBg = isLight ? const Color(0xFFFFFFFF) : const Color(0xFF0F172A);
    final cardBg = isLight ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B);
    final titleColor = isLight ? const Color(0xFF0F172A) : Colors.white;
    final subtitleColor = isLight ? const Color(0xFF475569) : Colors.white70;

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isLight ? const Color(0xFFCBD5E1) : Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary
                          .withValues(alpha: isLight ? 0.12 : 0.3),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      '/${info.symbol}/',
                      style: GoogleFonts.firaCode(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          info.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                          ),
                        ),
                        Text(
                          'Ejemplo: "${info.exampleWord}" ${info.exampleIpa}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: isLight
                          ? const Color(0xFFE2E8F0)
                          : const Color(0xFF334155)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol(isLight, 'Intentos', '$attempts'),
                    _buildStatCol(isLight, 'Aciertos', '$successes'),
                    _buildStatCol(isLight, 'GOP Reciente',
                        attempts > 0 ? '${score.round()}%' : '-'),
                    _buildStatCol(
                        isLight,
                        'Wilson 95%',
                        attempts >= 8
                            ? '${(wilson * 100).round()}%'
                            : 'Muestreo (<8)'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Trampa del hispanohablante (L1 Transfer):',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD97706),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                info.spanishTrapDescription,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, color: subtitleColor, height: 1.4),
              ),
              const SizedBox(height: 12),
              Text(
                'Consejo de articulación mecánica:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0284C7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                info.articulationTip,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, color: subtitleColor, height: 1.4),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    AppHaptics.medium();
                    Navigator.of(ctx).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            HvptExerciseScreen(targetPhoneme: info.symbol),
                      ),
                    );
                  },
                  icon: const Icon(Icons.headphones_rounded, size: 20),
                  label: Text(
                    'Entrenar Discriminación A/B (HVPT)',
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCol(bool isLight, String label, String val) {
    return Column(
      children: [
        Text(
          val,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isLight ? const Color(0xFF0F172A) : Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: isLight ? const Color(0xFF64748B) : Colors.white54,
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(BuildContext context, bool isLight) {
    final bg = isLight ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
    final border = isLight ? const Color(0xFFE2E8F0) : const Color(0xFF334155);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          _buildLegendDot(
              const Color(0xFF10B981), 'Dominado (≥80%)', isLight),
          _buildLegendDot(
              const Color(0xFFF59E0B), 'En progreso (60-79%)', isLight),
          _buildLegendDot(
              const Color(0xFFEF4444), 'Atención (<60%)', isLight),
          _buildLegendDot(
              isLight ? const Color(0xFF94A3B8) : Colors.white38,
              'Muestreo (<8)',
              isLight),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color col, String label, bool isLight) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: col, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: isLight ? const Color(0xFF475569) : Colors.white60,
          ),
        ),
      ],
    );
  }
}
