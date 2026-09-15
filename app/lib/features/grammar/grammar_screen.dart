import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import 'grammar_models.dart';
import 'grammar_theme_tokens.dart';
import 'grammar_topic_guide.dart';
import 'grammar_drill_runner.dart';

/// Pantalla de Guía de Gramática Dinámica, Interactiva y Ejecutiva
/// - Sin barra superior ni botón de atrás arriba para maximizar el espacio útil
/// - 1. Árbol de Decisión Interactivo (Mental Model Wizard con botones Sí / No)
/// - 2. Constructor Sintáctico por Bloques (Interactive Syntax Builder en vivo con audio)
/// - 3. Matriz Comparativa con Modo Desafío (Spot the Trap con botón para revelar y audio)
/// - 4. Personalizador Interactivo de Plantillas Pro (con presets por especialidad técnica)
/// - 5. Micro-Checkpoint de Autoevaluación interactivo con feedback instantáneo
/// - Casos reales contextuales con reproducción de audio TTS
/// - Barra inferior fija con botón Volver, marcador y acceso a práctica
class GrammarScreen extends ConsumerStatefulWidget {
  final GrammarUnit? unit;

  const GrammarScreen({super.key, this.unit});

  @override
  ConsumerState<GrammarScreen> createState() => _GrammarScreenState();
}

class _GrammarScreenState extends ConsumerState<GrammarScreen> {
  bool _isBookmarked = false;
  late final GrammarUnit _unit;
  late final GrammarTopicGuide _guide;

  // Estados interactivos
  bool? _decisionAnswer; // null = sin elegir, true = SÍ, false = NO
  late Map<int, int> _syntaxSlotSelections;
  bool _isChallengeMode = false;
  final Set<int> _revealedChallenges = {};
  late Map<int, int> _templatePresetSelections;
  int? _selectedCheckpointIndex;

  @override
  void initState() {
    super.initState();
    _unit = widget.unit ?? allGrammarUnits.first;
    _guide = getGrammarTopicGuide(_unit);

    // Inicializar ranuras del constructor sintáctico
    _syntaxSlotSelections = {
      for (int i = 0; i < _guide.syntaxBuilder.slots.length; i++) i: 0,
    };

    // Inicializar presets de plantillas interactivas
    _templatePresetSelections = {
      for (int i = 0; i < _guide.interactiveTemplates.length; i++) i: 0,
    };
  }

  void _startPractice() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GrammarDrillRunner(unit: _unit),
      ),
    );
  }

  void _navigateBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go('/grammar');
    }
  }

  void _playTts(String text) {
    if (text.trim().isEmpty) return;
    ref.read(audioPlayerProvider).playTts(text);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeIsLightProvider);
    final unit = _unit;
    final guide = _guide;
    final cleanTitle = unit.title.replaceFirst(RegExp(r'^Unit \d+: '), '');

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        top: true,
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Cabecera Dinámica de la Unidad (Aprovechamiento total de pantalla)
              _buildUnitHeader(cleanTitle, unit, guide),
              const SizedBox(height: 16),

              // 2. Regla de Oro Ejecutiva
              _buildGoldenRuleCard(unit),
              const SizedBox(height: 18),

              // 3. Fórmulas Sintácticas Dinámicas (+, -, ?)
              _buildFormulasCard(guide),
              const SizedBox(height: 18),

              // 4. INTERACTIVO: Constructor Sintáctico por Bloques en Vivo
              _buildInteractiveSyntaxBuilderCard(guide),
              const SizedBox(height: 18),

              // 5. INTERACTIVO: Árbol de Decisión Mental (Wizard Sí / No)
              _buildInteractiveDecisionCard(guide),
              const SizedBox(height: 18),

              // 6. Triggers y Palabras Clave
              if (guide.keyTriggers.isNotEmpty) ...[
                _buildTriggersCard(guide),
                const SizedBox(height: 18),
              ],

              // 7. INTERACTIVO: Matriz Comparativa con Modo Desafío (Spot the Trap)
              _buildComparativeMatrix(unit),
              const SizedBox(height: 18),

              // 8. Reglas de Morfología, Ortografía y Puntuación
              if (guide.morphologyAndRules.isNotEmpty) ...[
                _buildMorphologyRulesCard(guide),
                const SizedBox(height: 18),
              ],

              // 9. INTERACTIVO: Personalizador de Plantillas de Comunicación Técnica
              if (guide.interactiveTemplates.isNotEmpty) ...[
                _buildInteractiveTemplatesCard(guide),
                const SizedBox(height: 18),
              ],

              // 10. INTERACTIVO: Micro-Checkpoint de Autoevaluación
              _buildInteractiveCheckpointCard(guide),
              const SizedBox(height: 18),

              // 11. Guía de Criterio de Decisión y Trampa en Español
              _buildDecisionAndTrapCard(guide),
              const SizedBox(height: 18),

              // 12. Casos Reales en Entrevistas y Trabajo Técnico con Audio
              if (unit.questions.isNotEmpty) ...[
                _buildRealWorldExamplesCard(unit),
              ],
            ],
          ),
        ),
      ),
      // Sticky Bottom Dock con navegación limpia y acceso a práctica
      bottomNavigationBar: _buildStickyBottomDock(unit),
    );
  }

  /// 1. Cabecera Dinámica sin barra superior estorbosa
  Widget _buildUnitHeader(String cleanTitle, GrammarUnit unit, GrammarTopicGuide guide) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GrammarTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GrammarTheme.surfaceContainerHigh),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: GrammarTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: GrammarTheme.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded, size: 14, color: GrammarTheme.primary),
                    const SizedBox(width: 5),
                    Text(
                      'Nivel ${unit.tag}',
                      style: GrammarTheme.labelSm(
                        color: GrammarTheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: GrammarTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: GrammarTheme.surfaceContainerHigh),
                ),
                child: Text(
                  guide.categoryName,
                  style: GrammarTheme.labelSm(
                    color: GrammarTheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: GrammarTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.touch_app_rounded, size: 13, color: GrammarTheme.secondary),
                    const SizedBox(width: 4),
                    Text(
                      'Guía Interactiva',
                      style: GrammarTheme.labelSm(
                        color: GrammarTheme.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            cleanTitle,
            style: GrammarTheme.headlineSm(fontWeight: FontWeight.w800).copyWith(
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            unit.subtitle,
            style: GrammarTheme.bodyMd(
              color: GrammarTheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ).copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }

  /// 2. Regla de Oro Ejecutiva
  Widget _buildGoldenRuleCard(GrammarUnit unit) {
    return Container(
      decoration: BoxDecoration(
        color: GrammarTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GrammarTheme.surfaceContainerHigh),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 5,
            child: Container(color: GrammarTheme.primary),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: GrammarTheme.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.lightbulb_rounded, size: 20, color: GrammarTheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Regla de Oro Ejecutiva',
                        style: GrammarTheme.titleSm(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        unit.ruleSummary,
                        style: GrammarTheme.bodyMd(
                          color: GrammarTheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ).copyWith(height: 1.45),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Fórmulas Sintácticas Dinámicas (+, -, ?)
  Widget _buildFormulasCard(GrammarTopicGuide guide) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: GrammarTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GrammarTheme.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.terminal_rounded, size: 22, color: GrammarTheme.primary),
              const SizedBox(width: 8),
              Text(
                'Fórmulas y Estructuras Sintácticas',
                style: GrammarTheme.titleMd(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Patrones verbales clave para estructurar tus intervenciones con soltura técnica:',
            style: GrammarTheme.bodySm(color: GrammarTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 14),

          _buildFormulaRow(
            badge: '+ AFIRMATIVA',
            badgeColor: const Color(0xFF1B8755),
            formulaTokens: guide.affirmativeFormula,
            exampleSentence: guide.affirmativeExample,
          ),
          const SizedBox(height: 14),

          _buildFormulaRow(
            badge: '- NEGATIVA',
            badgeColor: const Color(0xFFD9383A),
            formulaTokens: guide.negativeFormula,
            exampleSentence: guide.negativeExample,
          ),
          const SizedBox(height: 14),

          _buildFormulaRow(
            badge: '? PREGUNTA',
            badgeColor: GrammarTheme.primary,
            formulaTokens: guide.questionFormula,
            exampleSentence: guide.questionExample,
          ),
        ],
      ),
    );
  }

  Widget _buildFormulaRow({
    required String badge,
    required Color badgeColor,
    required List<String> formulaTokens,
    required String exampleSentence,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GrammarTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GrammarTheme.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badge,
              style: GrammarTheme.labelSm(
                color: badgeColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 8),

          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (int i = 0; i < formulaTokens.length; i++) ...[
                if (i > 0)
                  Text(
                    formulaTokens[i].toLowerCase() == 'vs' ? 'vs' : '+',
                    style: TextStyle(
                      color: GrammarTheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                _formulaChip(
                  formulaTokens[i],
                  formulaTokens[i].toLowerCase() == 'vs'
                      ? Colors.transparent
                      : GrammarTheme.surfaceContainerHighest,
                  GrammarTheme.onSurface,
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: GrammarTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: GrammarTheme.surfaceContainerHigh),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '“$exampleSentence”',
                    style: GrammarTheme.bodyMd(
                      color: GrammarTheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ).copyWith(fontStyle: FontStyle.italic),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up_rounded, size: 20),
                  color: GrammarTheme.primary,
                  tooltip: 'Escuchar pronunciación',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                  onPressed: () => _playTts(exampleSentence),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _formulaChip(String label, Color bg, Color text) {
    if (label.toLowerCase() == 'vs') return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GrammarTheme.labelSm(
          color: text,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// 4. INTERACTIVO: Constructor Sintáctico por Bloques en Vivo (Syntax Builder)
  Widget _buildInteractiveSyntaxBuilderCard(GrammarTopicGuide guide) {
    final builder = guide.syntaxBuilder;

    // Construir la frase activa combinando las ranuras seleccionadas
    final assembledParts = <String>[];
    for (int i = 0; i < builder.slots.length; i++) {
      final slot = builder.slots[i];
      final sel = _syntaxSlotSelections[i] ?? 0;
      final safeIndex = (sel >= 0 && sel < slot.options.length) ? sel : 0;
      assembledParts.add(slot.options[safeIndex]);
    }
    final fullAssembledSentence = assembledParts.join(' ');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: GrammarTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GrammarTheme.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: GrammarTheme.primary.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.extension_rounded, size: 22, color: GrammarTheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Constructor de Frases Interactivo',
                    style: GrammarTheme.titleMd(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: GrammarTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 12, color: GrammarTheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      'En Vivo',
                      style: GrammarTheme.labelSm(
                        color: GrammarTheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Toca las opciones de cada bloque para ensamblar tu frase técnica en tiempo real:',
            style: GrammarTheme.bodySm(color: GrammarTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 14),

          // Selector interactivo de bloques
          for (int slotIdx = 0; slotIdx < builder.slots.length; slotIdx++) ...[
            _buildSlotSelector(slotIdx, builder.slots[slotIdx]),
            if (slotIdx < builder.slots.length - 1) const SizedBox(height: 10),
          ],

          const SizedBox(height: 14),

          // Frase Ensamblada Resultante con Audio Inmediato
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: GrammarTheme.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: GrammarTheme.primary.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'FRASE TÉCNICA ENSAMBLADA:',
                      style: GrammarTheme.labelSm(
                        color: GrammarTheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded, size: 22),
                      color: GrammarTheme.primary,
                      tooltip: 'Escuchar frase ensamblada',
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      onPressed: () => _playTts(fullAssembledSentence),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '“$fullAssembledSentence”',
                  style: GrammarTheme.bodyLg(
                    color: GrammarTheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ).copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotSelector(int slotIndex, SyntaxSlot slot) {
    final currentSelection = _syntaxSlotSelections[slotIndex] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bloque ${slotIndex + 1}: ${slot.label}',
          style: GrammarTheme.labelSm(
            color: GrammarTheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (int optIdx = 0; optIdx < slot.options.length; optIdx++) ...[
              _buildSlotOptionChip(
                slotIndex: slotIndex,
                optionIndex: optIdx,
                text: slot.options[optIdx],
                isSelected: currentSelection == optIdx,
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildSlotOptionChip({
    required int slotIndex,
    required int optionIndex,
    required String text,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _syntaxSlotSelections[slotIndex] = optionIndex;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? GrammarTheme.primary
              : GrammarTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? GrammarTheme.primary
                : GrammarTheme.surfaceContainerHigh,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          text,
          style: GrammarTheme.labelSm(
            color: isSelected ? Colors.white : GrammarTheme.onSurface,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// 5. INTERACTIVO: Árbol de Decisión Mental (Wizard Sí / No)
  Widget _buildInteractiveDecisionCard(GrammarTopicGuide guide) {
    final step = guide.decisionStep;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: GrammarTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GrammarTheme.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.alt_route_rounded, size: 22, color: GrammarTheme.primary),
              const SizedBox(width: 8),
              Text(
                'Árbol de Decisión Mental Interactivo',
                style: GrammarTheme.titleMd(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Entrena tu cerebro para responder en milisegundos sin traducir:',
            style: GrammarTheme.bodySm(color: GrammarTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 14),

          // Pregunta del Wizard
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: GrammarTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GrammarTheme.surfaceContainerHigh),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.help_outline_rounded, size: 18, color: GrammarTheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        step.question,
                        style: GrammarTheme.bodyMd(
                          color: GrammarTheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ).copyWith(height: 1.35),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Botones interactivos Sí / No
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() => _decisionAnswer = true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _decisionAnswer == true
                              ? const Color(0xFF1B8755)
                              : GrammarTheme.surfaceContainerHighest,
                          foregroundColor: _decisionAnswer == true
                              ? Colors.white
                              : GrammarTheme.onSurface,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: Icon(
                          Icons.check_circle_outline_rounded,
                          size: 16,
                          color: _decisionAnswer == true ? Colors.white : const Color(0xFF1B8755),
                        ),
                        label: const Text(
                          'SÍ',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() => _decisionAnswer = false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _decisionAnswer == false
                              ? GrammarTheme.secondary
                              : GrammarTheme.surfaceContainerHighest,
                          foregroundColor: _decisionAnswer == false
                              ? Colors.white
                              : GrammarTheme.onSurface,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: Icon(
                          Icons.cancel_outlined,
                          size: 16,
                          color: _decisionAnswer == false ? Colors.white : GrammarTheme.secondary,
                        ),
                        label: const Text(
                          'NO',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Resultado interactivo según la respuesta
          if (_decisionAnswer != null) ...[
            const SizedBox(height: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _decisionAnswer == true
                    ? const Color(0xFF1B8755).withValues(alpha: 0.1)
                    : GrammarTheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _decisionAnswer == true
                      ? const Color(0xFF1B8755).withValues(alpha: 0.3)
                      : GrammarTheme.secondary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _decisionAnswer == true ? '✓ CAMINO GRAMATICAL RECOMENDADO' : 'ℹ️ RAMA ALTERNATIVA',
                        style: GrammarTheme.labelSm(
                          color: _decisionAnswer == true ? const Color(0xFF1B8755) : GrammarTheme.secondary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded, size: 18),
                        color: _decisionAnswer == true ? const Color(0xFF1B8755) : GrammarTheme.secondary,
                        tooltip: 'Escuchar recomendación',
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          _playTts(_decisionAnswer == true ? step.yesOutcome : step.noOutcome);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _decisionAnswer == true ? step.yesOutcome : step.noOutcome,
                    style: GrammarTheme.titleSm(
                      color: GrammarTheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _decisionAnswer == true ? step.yesReason : step.noReason,
                    style: GrammarTheme.bodySm(
                      color: GrammarTheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ).copyWith(height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 6. Triggers y Palabras Clave
  Widget _buildTriggersCard(GrammarTopicGuide guide) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GrammarTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GrammarTheme.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt_rounded, size: 20, color: GrammarTheme.secondary),
              const SizedBox(width: 8),
              Text(
                'Disparadores y Palabras Clave (Triggers)',
                style: GrammarTheme.titleSm(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Cuando escuches o escribas estas señales en una prueba o standup, aplica esta estructura:',
            style: GrammarTheme.bodySm(color: GrammarTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: guide.keyTriggers.map((trigger) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: GrammarTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: GrammarTheme.surfaceContainerHigh),
                ),
                child: Text(
                  trigger,
                  style: GrammarTheme.labelSm(
                    color: GrammarTheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 7. INTERACTIVO: Matriz Comparativa con Modo Desafío (Spot the Trap)
  Widget _buildComparativeMatrix(GrammarUnit unit) {
    final examples = unit.comparisonExamples;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Matriz Comparativa Ejecutiva',
              style: GrammarTheme.headlineSm(fontWeight: FontWeight.w700),
            ),
            // Toggle interactivo de Modo Estudio vs Modo Desafío
            InkWell(
              onTap: () {
                setState(() {
                  _isChallengeMode = !_isChallengeMode;
                  _revealedChallenges.clear();
                });
              },
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _isChallengeMode
                      ? GrammarTheme.primary.withValues(alpha: 0.15)
                      : GrammarTheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: _isChallengeMode ? GrammarTheme.primary : GrammarTheme.surfaceContainerHigh,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isChallengeMode ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      size: 13,
                      color: _isChallengeMode ? GrammarTheme.primary : GrammarTheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isChallengeMode ? 'Modo Desafío' : 'Modo Estudio',
                      style: GrammarTheme.labelSm(
                        color: _isChallengeMode ? GrammarTheme.primary : GrammarTheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _isChallengeMode
              ? '🎯 Intenta detectar el error técnico en la frase antes de pulsar "Revelar Corrección":'
              : 'Contraste directo entre opciones confusas y formulaciones de alto impacto:',
          style: GrammarTheme.bodySm(color: GrammarTheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),

        if (examples.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: GrammarTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'Esta unidad se enfoca en aplicación contextual directa.',
              style: GrammarTheme.bodyMd(),
            ),
          )
        else
          for (int i = 0; i < examples.length; i++) ...[
            _buildInteractiveComparisonCard(examples[i], index: i),
            if (i < examples.length - 1) const SizedBox(height: 12),
          ],
      ],
    );
  }

  Widget _buildInteractiveComparisonCard(Map<String, String> item, {required int index}) {
    final wrong = item['wrong'] ?? '';
    final right = item['right'] ?? '';
    final tip = item['tip'] ?? item['note'] ?? item['explanation'] ?? '';
    final isRevealed = !_isChallengeMode || _revealedChallenges.contains(index);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GrammarTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GrammarTheme.surfaceContainerHigh),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Frase con Error (Wrong)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: GrammarTheme.errorContainer.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GrammarTheme.error.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.cancel_rounded, size: 16, color: GrammarTheme.error),
                        const SizedBox(width: 6),
                        Text(
                          _isChallengeMode ? 'FRASE CON ERROR / TRAMPA' : 'OPCIÓN CONFUSA / PENALIZADA',
                          style: GrammarTheme.labelSm(
                            color: GrammarTheme.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    if (_isChallengeMode && !isRevealed)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '¿Ves el error?',
                          style: GrammarTheme.labelSm(
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '“$wrong”',
                  style: GrammarTheme.titleSm(
                    color: GrammarTheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ).copyWith(
                    decoration: isRevealed ? TextDecoration.lineThrough : null,
                    decorationColor: GrammarTheme.error,
                  ),
                ),
              ],
            ),
          ),

          // Si estamos en modo desafío y aún no está revelado, botón de acción
          if (_isChallengeMode && !isRevealed) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() => _revealedChallenges.add(index));
                  _playTts(right);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: GrammarTheme.primary,
                  side: BorderSide(color: GrammarTheme.primary.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.visibility_rounded, size: 16),
                label: Text(
                  'Revelar Corrección y Escuchar Audio',
                  style: GrammarTheme.labelMd(
                    color: GrammarTheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],

          // Opción de Alto Impacto (Right) y Tip (Revelados)
          if (isRevealed) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1B8755).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1B8755).withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF1B8755)),
                          const SizedBox(width: 6),
                          Text(
                            'OPCIÓN DE ALTO IMPACTO (RECOMENDADA)',
                            style: GrammarTheme.labelSm(
                              color: const Color(0xFF1B8755),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded, size: 18),
                        color: const Color(0xFF1B8755),
                        tooltip: 'Escuchar opción correcta',
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        onPressed: () => _playTts(right),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '“$right”',
                    style: GrammarTheme.titleSm(
                      color: GrammarTheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            if (tip.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: GrammarTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.psychology_rounded, size: 18, color: GrammarTheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: GrammarTheme.bodySm(
                          color: GrammarTheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ).copyWith(height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  /// 8. Reglas de Morfología, Ortografía y Puntuación
  Widget _buildMorphologyRulesCard(GrammarTopicGuide guide) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: GrammarTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GrammarTheme.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book_rounded, size: 22, color: GrammarTheme.primary),
              const SizedBox(width: 8),
              Text(
                'Morfología, Ortografía y Puntuación',
                style: GrammarTheme.titleMd(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Detalles normativos que marcan la diferencia entre un nivel B1 y un profesional senior:',
            style: GrammarTheme.bodySm(color: GrammarTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),

          for (final item in guide.morphologyAndRules) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: GrammarTheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: GrammarTheme.bodyMd(
                        color: GrammarTheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ).copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 9. INTERACTIVO: Personalizador de Plantillas de Comunicación Técnica
  Widget _buildInteractiveTemplatesCard(GrammarTopicGuide guide) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: GrammarTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GrammarTheme.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.content_paste_go_rounded, size: 22, color: GrammarTheme.primary),
              const SizedBox(width: 8),
              Text(
                'Plantillas de Comunicación Técnica',
                style: GrammarTheme.titleMd(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Toca las diferentes especialidades para adaptar la plantilla a tu rol:',
            style: GrammarTheme.bodySm(color: GrammarTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 14),

          for (int tmplIdx = 0; tmplIdx < guide.interactiveTemplates.length; tmplIdx++) ...[
            _buildInteractiveTemplateItem(tmplIdx, guide.interactiveTemplates[tmplIdx]),
            if (tmplIdx < guide.interactiveTemplates.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildInteractiveTemplateItem(int tmplIndex, InteractiveProTemplate tmpl) {
    final selPreset = _templatePresetSelections[tmplIndex] ?? 0;
    final safePresetIndex = (selPreset >= 0 && selPreset < tmpl.presets.length) ? selPreset : 0;
    final activePreset = tmpl.presets[safePresetIndex];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GrammarTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GrammarTheme.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tmpl.title,
                style: GrammarTheme.titleSm(fontWeight: FontWeight.w700),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: GrammarTheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Pro Template',
                  style: GrammarTheme.labelSm(color: GrammarTheme.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Chips para alternar presets técnicos
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (int pIdx = 0; pIdx < tmpl.presets.length; pIdx++) ...[
                InkWell(
                  onTap: () {
                    setState(() {
                      _templatePresetSelections[tmplIndex] = pIdx;
                    });
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: safePresetIndex == pIdx
                          ? GrammarTheme.primary
                          : GrammarTheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: safePresetIndex == pIdx
                            ? GrammarTheme.primary
                            : GrammarTheme.surfaceContainerHigh,
                      ),
                    ),
                    child: Text(
                      tmpl.presets[pIdx].tag,
                      style: GrammarTheme.labelSm(
                        color: safePresetIndex == pIdx ? Colors.white : GrammarTheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),

          // Ejemplo adaptado con audio
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: GrammarTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: GrammarTheme.surfaceContainerHigh),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    '“${activePreset.fullSentence}”',
                    style: GrammarTheme.bodyMd(
                      color: GrammarTheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ).copyWith(height: 1.4),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up_rounded, size: 20),
                  color: GrammarTheme.primary,
                  tooltip: 'Escuchar frase',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                  onPressed: () => _playTts(activePreset.fullSentence),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Uso: ${tmpl.contextUsage}',
            style: GrammarTheme.labelSm(
              color: GrammarTheme.onSurfaceVariant,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  /// 10. INTERACTIVO: Micro-Checkpoint de Autoevaluación en 1 Toque
  Widget _buildInteractiveCheckpointCard(GrammarTopicGuide guide) {
    final checkpoint = guide.checkpoint;
    final sel = _selectedCheckpointIndex;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: GrammarTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GrammarTheme.secondary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: GrammarTheme.secondary.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.quiz_rounded, size: 22, color: GrammarTheme.secondary),
                  const SizedBox(width: 8),
                  Text(
                    'Micro-Checkpoint Interactivo',
                    style: GrammarTheme.titleMd(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: GrammarTheme.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '1 Toque',
                  style: GrammarTheme.labelSm(
                    color: GrammarTheme.secondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            checkpoint.situation,
            style: GrammarTheme.labelSm(
              color: GrammarTheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            checkpoint.question,
            style: GrammarTheme.bodyMd(
              color: GrammarTheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          // Opciones de respuesta interactiva
          for (int i = 0; i < checkpoint.options.length; i++) ...[
            _buildCheckpointOptionRow(i, checkpoint.options[i]),
            if (i < checkpoint.options.length - 1) const SizedBox(height: 8),
          ],

          // Feedback pedagógico inmediato
          if (sel != null && sel >= 0 && sel < checkpoint.options.length) ...[
            const SizedBox(height: 12),
            _buildCheckpointFeedback(checkpoint.options[sel]),
          ],
        ],
      ),
    );
  }

  Widget _buildCheckpointOptionRow(int index, CheckpointOption option) {
    final isSelected = _selectedCheckpointIndex == index;
    final isAnswered = _selectedCheckpointIndex != null;

    Color borderColor = GrammarTheme.surfaceContainerHigh;
    Color bgColor = GrammarTheme.surfaceContainerLow;
    IconData leadingIcon = Icons.radio_button_unchecked_rounded;
    Color iconColor = GrammarTheme.onSurfaceVariant;

    if (isSelected) {
      if (option.isCorrect) {
        borderColor = const Color(0xFF1B8755);
        bgColor = const Color(0xFF1B8755).withValues(alpha: 0.1);
        leadingIcon = Icons.check_circle_rounded;
        iconColor = const Color(0xFF1B8755);
      } else {
        borderColor = GrammarTheme.error;
        bgColor = GrammarTheme.errorContainer.withValues(alpha: 0.25);
        leadingIcon = Icons.cancel_rounded;
        iconColor = GrammarTheme.error;
      }
    } else if (isAnswered && option.isCorrect) {
      borderColor = const Color(0xFF1B8755).withValues(alpha: 0.4);
      leadingIcon = Icons.check_circle_outline_rounded;
      iconColor = const Color(0xFF1B8755);
    }

    return InkWell(
      onTap: () {
        setState(() => _selectedCheckpointIndex = index);
        if (option.isCorrect) {
          _playTts(option.text);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(leadingIcon, size: 18, color: iconColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                option.text,
                style: GrammarTheme.bodyMd(
                  color: GrammarTheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ).copyWith(height: 1.35),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckpointFeedback(CheckpointOption option) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: option.isCorrect
            ? const Color(0xFF1B8755).withValues(alpha: 0.08)
            : GrammarTheme.errorContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: option.isCorrect
              ? const Color(0xFF1B8755).withValues(alpha: 0.3)
              : GrammarTheme.error.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            option.isCorrect ? Icons.verified_rounded : Icons.info_outline_rounded,
            size: 18,
            color: option.isCorrect ? const Color(0xFF1B8755) : GrammarTheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              option.feedback,
              style: GrammarTheme.bodySm(
                color: GrammarTheme.onSurface,
                fontWeight: FontWeight.w500,
              ).copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  /// 11. Criterio de Decisión y Trampa para Hispanohablantes
  Widget _buildDecisionAndTrapCard(GrammarTopicGuide guide) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: GrammarTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GrammarTheme.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.rule_rounded, size: 22, color: GrammarTheme.primary),
              const SizedBox(width: 8),
              Text(
                'Guía de Decisión Rápida',
                style: GrammarTheme.titleMd(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_outline_rounded, size: 18, color: Color(0xFF1B8755)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¿CUÁNDO USARLO?',
                      style: GrammarTheme.labelSm(
                        color: const Color(0xFF1B8755),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      guide.whenToUse,
                      style: GrammarTheme.bodySm(color: GrammarTheme.onSurface),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.block_rounded, size: 18, color: Color(0xFFD9383A)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¿CUÁNDO EVITARLO?',
                      style: GrammarTheme.labelSm(
                        color: const Color(0xFFD9383A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      guide.whenNotToUse,
                      style: GrammarTheme.bodySm(color: GrammarTheme.onSurface),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 20, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TRAMPA COMÚN PARA HISPANOHABLANTES',
                        style: GrammarTheme.labelSm(
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        guide.spanishTrapTip,
                        style: GrammarTheme.bodySm(
                          color: GrammarTheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ).copyWith(height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 12. Casos Reales en Entrevistas y Trabajo Técnico
  Widget _buildRealWorldExamplesCard(GrammarUnit unit) {
    final questions = unit.questions;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: GrammarTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GrammarTheme.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.work_outline_rounded, size: 22, color: GrammarTheme.primary),
              const SizedBox(width: 8),
              Text(
                'Casos Reales en Entrevistas y Trabajo',
                style: GrammarTheme.titleMd(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Frases técnicas completas con audio y desglose para aplicar en tu día a día profesional:',
            style: GrammarTheme.bodySm(color: GrammarTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),

          for (int i = 0; i < questions.length; i++) ...[
            _buildSampleQuestionRow(questions[i], index: i + 1),
            if (i < questions.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildSampleQuestionRow(GrammarQuestion q, {required int index}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GrammarTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GrammarTheme.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (q.contextSentence != null && q.contextSentence!.isNotEmpty) ...[
            Text(
              q.contextSentence!,
              style: GrammarTheme.labelSm(
                color: GrammarTheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Row(
            children: [
              Expanded(
                child: Text(
                  '“${q.audioText}”',
                  style: GrammarTheme.bodyMd(
                    color: GrammarTheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up_rounded, size: 20),
                color: GrammarTheme.primary,
                tooltip: 'Escuchar frase',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
                onPressed: () => _playTts(q.audioText),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 14, color: GrammarTheme.secondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  q.spanishExplanation,
                  style: GrammarTheme.bodySm(
                    color: GrammarTheme.onSurfaceVariant,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Sticky Bottom Action Dock (con botón Volver y acceso a práctica)
  Widget _buildStickyBottomDock(GrammarUnit unit) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: GrammarTheme.surface.withValues(alpha: 0.96),
        border: Border(
          top: BorderSide(
            color: GrammarTheme.surfaceContainerHigh,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            OutlinedButton.icon(
              onPressed: _navigateBack,
              style: OutlinedButton.styleFrom(
                foregroundColor: GrammarTheme.onSurface,
                side: BorderSide(color: GrammarTheme.surfaceContainerHighest),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: Text(
                'Volver',
                style: GrammarTheme.labelMd(
                  color: GrammarTheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),

            InkWell(
              onTap: () {
                setState(() => _isBookmarked = !_isBookmarked);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 1),
                    content: Text(
                      _isBookmarked ? 'Guardado en tus marcadores' : 'Eliminado de marcadores',
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: GrammarTheme.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: _isBookmarked ? GrammarTheme.primary : GrammarTheme.onSurface,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 10),

            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _startPractice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GrammarTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded, size: 20, color: Colors.white),
                  label: Text(
                    'Practicar Tema (${unit.questions.length})',
                    style: GrammarTheme.labelMd(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
