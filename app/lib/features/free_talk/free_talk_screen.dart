import 'dart:async';
import 'dart:io' show File;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/audio/audio_player_controller.dart';
import '../../core/audio/audio_recorder_controller.dart';
import '../../core/network/api_client.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/ai_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tab_theme.dart';
import 'free_talk_home_view.dart';

/// Modelo local para los mensajes del chat interactivo
class FreeTalkChatMessage {
  final String role; // 'user' o 'assistant'
  final String content;
  final String? audioUrl;
  final DateTime timestamp;
  final bool isFromVoice;
  final FreeTalkEvaluation? evaluation;

  FreeTalkChatMessage({
    required this.role,
    required this.content,
    this.audioUrl,
    DateTime? timestamp,
    this.isFromVoice = false,
    this.evaluation,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isUser => role == 'user';
}

class FreeTalkScreen extends ConsumerStatefulWidget {
  final String? initialTopic;

  const FreeTalkScreen({super.key, this.initialTopic});

  @override
  ConsumerState<FreeTalkScreen> createState() => _FreeTalkScreenState();
}

class _FreeTalkScreenState extends ConsumerState<FreeTalkScreen> with TickerProviderStateMixin {
  final List<FreeTalkChatMessage> _messages = [];

  // --- Medición de la sesión (progreso/diario/racha) ---
  DateTime? _sessionStart;
  int _assistantTurns = 0;
  bool _sessionRecorded = false;
  final List<Map<String, String>> _sessionMistakes = [];
  final List<String> _sessionVocab = [];
  final List<int> _fluencyScores = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late AnimationController _orbAnimController;
  late AnimationController _pulseAnimController;

  bool _isProcessing = false;
  bool _autoPlayAudio = true;
  String _selectedTopic = 'Tech Architecture & Trade-offs';
  String _selectedLevel = 'B2';
  int? _expandedTurnIndex;

  // --- Vista home tipo mural (voz-first) ---
  bool _showTranscript = false; // false = orbe; true = chat de burbujas
  bool _showTextInput = false; // barra de texto de respaldo
  String _streamingReply = ''; // respuesta de Lito formándose en vivo (streaming)

  final List<String> _topics = const [
    'Tech Architecture & Trade-offs',
    'Incident RCA & Post-Mortem',
    'Agile Daily & Sprint Blockers',
    'System Design & Latency',
    'Salary & Senior Offer Negotiation',
    'Casual Tech Coffee Chat',
  ];

  @override
  void initState() {
    super.initState();
    _sessionStart = DateTime.now();
    if (widget.initialTopic != null && widget.initialTopic!.isNotEmpty) {
      _selectedTopic = widget.initialTopic!;
    }

    _orbAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _pulseAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(activeProfileProvider).valueOrNull;
      if (profile?.targetLevel != null && profile!.targetLevel.isNotEmpty) {
        setState(() => _selectedLevel = profile.targetLevel);
      }
      _sendInitialGreeting();
    });
  }

  /// Registra la sesión de Free Talk en el progreso (diario, minutos, XP,
  /// racha) reutilizando los servicios globales. Idempotente por sesión.
  Future<void> _recordSession() async {
    if (_sessionRecorded || _assistantTurns == 0) return;
    _sessionRecorded = true;
    // Capturamos los servicios ANTES de cualquier await (dispose seguro).
    final journal = ref.read(journalServiceProvider);
    final repo = ref.read(profileRepositoryProvider);
    final practice = ref.read(practiceServiceProvider);
    final userId = ref.read(activeUserIdProvider);
    final wasMounted = mounted;
    final start = _sessionStart ?? DateTime.now();
    final elapsed =
        DateTime.now().difference(start).inSeconds.clamp(30, 3600);
    final avg = _fluencyScores.isEmpty
        ? 0.0
        : _fluencyScores.reduce((a, b) => a + b) / _fluencyScores.length;
    final vocab = _sessionVocab.toSet().toList();
    try {
      await journal.recordActivityJournal(
        title:
            'Conversación libre con IA${_selectedTopic.isNotEmpty ? ' · $_selectedTopic' : ''}',
        category: 'Free Talk (Speaking)',
        date: start,
        durationSeconds: elapsed,
        overallScore: avg,
        questionsCount: _assistantTurns,
        mistakes: _sessionMistakes,
        vocabulary: vocab,
        additionalNotes:
            'Conversación oral con Lito: $_assistantTurns intervenciones, nivel $_selectedLevel.',
      );
      await repo.logLearningActivity(
        userId: userId,
        xp: _assistantTurns * 12 + 10,
        minutes: (elapsed / 60).ceil().clamp(1, 30),
        sessions: 1,
        words: vocab.length,
      );
      await practice.registerActivityDay(userId);
    } catch (_) {}
    if (wasMounted && mounted) {
      ref.invalidate(profileSummaryProvider);
      ref.invalidate(activeProfileProvider);
      ref.invalidate(dueCardsCountProvider);
    }
  }

  @override
  void dispose() {
    _recordSession(); // best-effort si se salió sin el botón
    _orbAnimController.dispose();
    _pulseAnimController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendInitialGreeting() {
    final profile = ref.read(activeProfileProvider).valueOrNull;
    final name = (profile?.displayName ?? '').trim().split(' ').first;
    final userGreeting = name.isNotEmpty ? ' $name' : '';

    final greeting = 'Hey$userGreeting! I\'m Lito, your AI tech lead and English coach. '
        'Today we are discussing "$_selectedTopic". '
        'What architectural challenge or project update have you been tackling lately?';

    setState(() {
      _messages.add(
        FreeTalkChatMessage(
          role: 'assistant',
          content: greeting,
        ),
      );
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  List<Map<String, String>> _buildHistoryForApi() {
    return _messages.map((m) {
      return {
        'role': m.role,
        'content': m.content,
      };
    }).toList();
  }

  Future<void> _handleSendMessage({String? overrideText, Uint8List? audioBytes, String? audioFileName}) async {
    final text = overrideText ?? _textController.text.trim();
    final hasAudio = audioBytes != null && audioBytes.isNotEmpty;

    if (text.isEmpty && !hasAudio) return;

    _textController.clear();
    FocusScope.of(context).unfocus();

    // Si es solo texto, agregamos de inmediato el mensaje del usuario a la lista
    if (!hasAudio) {
      setState(() {
        _messages.add(
          FreeTalkChatMessage(
            role: 'user',
            content: text,
            isFromVoice: false,
          ),
        );
        _isProcessing = true;
      });
      _scrollToBottom();
    } else {
      setState(() {
        _isProcessing = true;
      });
    }

    try {
      final aiService = ref.read(aiServiceProvider);
      final history = _buildHistoryForApi();

      final result = await aiService.streamFreeTalkTurn(
        audioBytes: audioBytes,
        audioFileName: audioFileName,
        userText: hasAudio ? null : text,
        conversationHistory: history,
        topic: _selectedTopic,
        targetLevel: _selectedLevel,
        onDelta: (_, fullReply) {
          if (mounted) setState(() => _streamingReply = fullReply);
        },
      );

      if (!mounted) return;

      if (result != null) {
        // Si fue por audio, agregamos la transcripción detectada
        if (hasAudio && result.userTranscript.isNotEmpty) {
          _messages.add(
            FreeTalkChatMessage(
              role: 'user',
              content: result.userTranscript,
              isFromVoice: true,
            ),
          );
        }

        final assistantMsg = FreeTalkChatMessage(
          role: 'assistant',
          content: result.replyText,
          audioUrl: result.audioUrl,
          evaluation: result.evaluation,
        );

        setState(() {
          _messages.add(assistantMsg);
          _expandedTurnIndex = _messages.length - 1; // Auto expandir evaluación del último turno
        });
        _scrollToBottom();

        // Medición: acumulamos el turno y marcamos hoy como día activo (racha).
        _assistantTurns++;
        for (final c in result.evaluation.grammarCorrections) {
          _sessionMistakes.add({
            'original': c.original,
            'correction': c.correction,
            'rule': c.explanation,
          });
        }
        for (final v in result.evaluation.vocabularySuggestions) {
          if (v.term.trim().isNotEmpty) _sessionVocab.add(v.term.trim());
        }
        _fluencyScores.add(result.fluencyScore);
        await ref
            .read(practiceServiceProvider)
            .registerActivityDay(ref.read(activeUserIdProvider));

        // Reproducir audio si está habilitado y hay URL
        if (_autoPlayAudio && result.audioUrl != null && result.audioUrl!.isNotEmpty) {
          final player = ref.read(audioPlayerProvider);
          player.playAudioUrl(result.audioUrl!);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No pudimos procesar la respuesta con Lito. Intenta de nuevo.'),
            backgroundColor: AppTheme.warning,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de conexión con el tutor: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _streamingReply = '';
        });
      }
    }
  }

  Future<void> _startRecording() async {
    final recorder = ref.read(audioRecorderProvider);
    try {
      HapticFeedback.heavyImpact();
      await recorder.startRecording();
    } catch (e) {
      debugPrint('[FreeTalk] startRecording error: $e');
    }
    if (!mounted) return;
    // Blindaje: si el micro no arrancó (permiso denegado, sin micro, error del
    // navegador…), avisamos en pantalla en vez de fallar en silencio.
    if (recorder.state != RecordingState.recording) {
      final es = Localizations.localeOf(context).languageCode == 'es';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(es
              ? 'No pude activar el micrófono. Revisa el permiso (navegador/app) y toca el orbe de nuevo.'
              : 'Could not start the mic. Check the permission (browser/app) and tap the orb again.'),
          backgroundColor: AppTheme.warning,
        ),
      );
    }
    setState(() {});
  }

  Future<void> _stopRecordingAndSend() async {
    final recorder = ref.read(audioRecorderProvider);
    if (recorder.state != RecordingState.recording) return;

    HapticFeedback.mediumImpact();
    final audioPath = await recorder.stopRecording();
    recorder.resetToIdle();

    if (audioPath == null) return;

    Uint8List? audioBytes;
    String fileName = 'speech.m4a';

    try {
      if (kIsWeb) {
        if (audioPath.startsWith('blob:') || audioPath.startsWith('http')) {
          final dio = ref.read(apiClientProvider).dio;
          final blobRes = await dio.get<List<int>>(
            audioPath,
            options: Options(responseType: ResponseType.bytes),
          );
          if (blobRes.data != null) {
            audioBytes = Uint8List.fromList(blobRes.data!);
          }
          fileName = 'speech.webm';
        }
      } else {
        // Móvil (Android/iOS) y escritorio: el audio quedó en un fichero en disco.
        // BUG ANTERIOR: esta rama era un placeholder y audioBytes quedaba null,
        // así que en el móvil NUNCA se enviaba nada. Ahora leemos los bytes.
        final f = File(audioPath);
        if (await f.exists()) {
          audioBytes = await f.readAsBytes();
        }
        final name = audioPath.split(RegExp(r'[\\/]')).last;
        if (name.isNotEmpty) fileName = name;
      }
    } catch (e) {
      debugPrint('[FreeTalk] Error fetching audio bytes: $e');
    }

    await _handleSendMessage(
      audioBytes: audioBytes,
      audioFileName: fileName,
    );
  }

  /// Estado del orbe derivado de grabacion / procesamiento / reproduccion.
  FreeTalkOrbState _computeOrbState(bool isRecording, bool isPlaying) {
    if (isRecording) return FreeTalkOrbState.listening;
    if (_isProcessing) return FreeTalkOrbState.thinking;
    if (isPlaying) return FreeTalkOrbState.speaking;
    return FreeTalkOrbState.idle;
  }

  /// Accion principal del orbe: alterna grabar / enviar.
  void _onOrbTap() {
    if (_isProcessing) return;
    final recorder = ref.read(audioRecorderProvider);
    if (recorder.state == RecordingState.recording) {
      _stopRecordingAndSend();
    } else {
      _startRecording();
    }
  }

  /// Ultimo mensaje de Lito, para el pill de contexto del orbe.
  String? get _lastAssistantReply {
    for (final m in _messages.reversed) {
      if (!m.isUser) return m.content;
    }
    return null;
  }

  /// Titulo de bienvenida con el nombre del perfil si existe.
  String _greetingTitle() {
    final profile = ref.read(activeProfileProvider).valueOrNull;
    final name = (profile?.displayName ?? '').trim().split(' ').first;
    final es = Localizations.localeOf(context).languageCode == 'es';
    if (name.isNotEmpty) return es ? '¡Hola, $name!' : 'Hi, $name!';
    return es ? '¡Hola!' : 'Hi!';
  }

  /// Bottom sheet para cambiar de tema sin salir del orbe.
  void _showTopicSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Localizations.localeOf(context).languageCode == 'es'
                    ? 'Elige un tema'
                    : 'Choose a topic',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ..._topics.map((t) {
                final selected = t == _selectedTopic;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    t,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  trailing: selected
                      ? Icon(Icons.check_circle_rounded, color: AppTheme.primary)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedTopic = t;
                      _messages.clear();
                      _sendInitialGreeting();
                    });
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recorder = ref.watch(audioRecorderProvider);
    final player = ref.watch(audioPlayerProvider);
    final isRecording = recorder.state == RecordingState.recording;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final orbState = _computeOrbState(isRecording, player.isPlaying);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark),
            if (_showTranscript) _buildTopicAndLevelBar(context, isDark),
            Expanded(
              child: _showTranscript
                  ? (_messages.isEmpty
                      ? _buildEmptyState(isDark)
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final msg = _messages[index];
                            return _buildChatBubble(msg, index, isDark);
                          },
                        ))
                  : FreeTalkHomeView(
                      state: orbState,
                      onOrbTap: _onOrbTap,
                      title: _greetingTitle(),
                      topicLabel: _selectedTopic,
                      lastReply: _streamingReply.isNotEmpty
                          ? _streamingReply
                          : _lastAssistantReply,
                      onOpenTopics: _showTopicSheet,
                      onToggleText: () {
                        setState(() => _showTextInput = !_showTextInput);
                      },
                      onShowTranscript: () {
                        setState(() => _showTranscript = true);
                      },
                    ),
            ),
            if (_isProcessing && _showTranscript) _buildThinkingIndicator(isDark),
            if (_showTranscript || _showTextInput)
              _buildBottomControls(recorder, isRecording, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131722) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(_showTranscript ? Icons.close_rounded : Icons.arrow_back_rounded),
            onPressed: () async {
              if (_showTranscript) {
                setState(() => _showTranscript = false);
                return;
              }
              await _recordSession();
              if (mounted) Navigator.of(context).pop();
            },
            tooltip: _showTranscript ? 'Volver al orbe' : 'Volver',
            style: IconButton.styleFrom(
              backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(width: 12),
          // Orb Avatar
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseAnimController,
                builder: (context, child) {
                  return Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          TabTheme.speaking.accent.withValues(alpha: 0.4 * _pulseAnimController.value),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  );
                },
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      TabTheme.speaking.accent,
                      const Color(0xFF00B4D8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: TabTheme.speaking.accent.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.record_voice_over_rounded, size: 18, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Lito AI Coach',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ONLINE',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF10B981),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  'Conversación libre técnica y feedback inmediato',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Toggle Auto Audio
          IconButton(
            icon: Icon(
              _autoPlayAudio ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: _autoPlayAudio ? TabTheme.speaking.accent : Colors.grey,
            ),
            tooltip: _autoPlayAudio ? 'Voz activada' : 'Voz silenciada',
            onPressed: () {
              setState(() => _autoPlayAudio = !_autoPlayAudio);
            },
          ),
          // Reset chat
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: 'Reiniciar sesión',
            onPressed: () {
              setState(() {
                _messages.clear();
                _sendInitialGreeting();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopicAndLevelBar(BuildContext context, bool isDark) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: isDark ? const Color(0xFF0F131D) : const Color(0xFFF8FAFC),
      child: Row(
        children: [
          Icon(Icons.topic_outlined, size: 16, color: TabTheme.speaking.accent),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _topics.map((t) {
                  final isSelected = t == _selectedTopic;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(t),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _selectedTopic = t;
                            _messages.clear();
                            _sendInitialGreeting();
                          });
                        }
                      },
                      labelStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
                      ),
                      selectedColor: TabTheme.speaking.accent,
                      backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isSelected
                              ? TabTheme.speaking.accent
                              : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0)),
                        ),
                      ),
                      showCheckmark: false,
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: TabTheme.speaking.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _selectedLevel,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: TabTheme.speaking.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.forum_outlined, size: 48, color: TabTheme.speaking.accent.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              'Inicia la conversación',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Habla con el micrófono o escribe abajo. Lito te responderá en audio natural y corregirá tu gramática al instante.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(FreeTalkChatMessage msg, int index, bool isDark) {
    final isUser = msg.isUser;
    final isExpanded = _expandedTurnIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: TabTheme.speaking.accent,
                  ),
                  child: const Icon(Icons.smart_toy_rounded, size: 16, color: Colors.white),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 580),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? TabTheme.speaking.accent
                        : (isDark ? const Color(0xFF1E2433) : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (msg.isFromVoice && isUser)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.mic_rounded, size: 12, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(
                                'Audio transcrito',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      SelectableText(
                        msg.content,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                          color: isUser
                              ? Colors.white
                              : (isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A)),
                        ),
                      ),
                      if (!isUser && msg.audioUrl != null && msg.audioUrl!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: InkWell(
                            onTap: () {
                              final player = ref.read(audioPlayerProvider);
                              player.playAudioUrl(msg.audioUrl!);
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: TabTheme.speaking.accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.play_arrow_rounded, size: 16, color: TabTheme.speaking.accent),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Escuchar pronunciación nativa',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: TabTheme.speaking.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (isUser) const SizedBox(width: 8),
            ],
          ),

          // Tarjeta Pedagógica Desplegable de Lito
          if (!isUser && msg.evaluation != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _expandedTurnIndex = isExpanded ? null : index;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome_rounded, size: 14, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 6),
                      Text(
                        'Análisis de Lito (Fluidez ${msg.evaluation!.fluencyScore}%)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: const Color(0xFFF59E0B),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.only(left: 36, top: 8),
                child: _buildEvaluationCard(msg.evaluation!, isDark),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildEvaluationCard(FreeTalkEvaluation eval, bool isDark) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 580),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B26) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFFF59E0B).withValues(alpha: 0.3) : const Color(0xFFFDE68A),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_outlined, size: 18, color: Color(0xFFF59E0B)),
              const SizedBox(width: 8),
              Text(
                'Feedback pedagógico del turno',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF92400E),
                ),
              ),
            ],
          ),
          if (eval.grammarCorrections.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'CORRECCIÓN GRAMATICAL:',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: const Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 6),
            ...eval.grammarCorrections.map((corr) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (corr.original.isNotEmpty)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('❌ ', style: TextStyle(fontSize: 11)),
                          Expanded(
                            child: Text(
                              corr.original,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                color: const Color(0xFFEF4444),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 3),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('✅ ', style: TextStyle(fontSize: 11)),
                        Expanded(
                          child: Text(
                            corr.correction,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (corr.explanation.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        corr.explanation,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontStyle: FontStyle.italic,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
          if (eval.vocabularySuggestions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'VOCABULARIO TÉCNICO B2/C1 SUGERIDO:',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: const Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: eval.vocabularySuggestions.map((v) {
                return Tooltip(
                  message: '${v.explanation}\nContexto: ${v.contextSentence}',
                  child: Chip(
                    label: Text(v.c1Alternative.isNotEmpty ? '${v.term} (${v.c1Alternative})' : v.term),
                    labelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2563EB),
                    ),
                    backgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                    side: BorderSide(color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                );
              }).toList(),
            ),
          ],
          if (eval.pronunciationTips.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'TIPS DE FONÉTICA Y CONNECTED SPEECH:',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: const Color(0xFF8B5CF6),
              ),
            ),
            const SizedBox(height: 6),
            ...eval.pronunciationTips.map((tip) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.record_voice_over_rounded, size: 14, color: Color(0xFF8B5CF6)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        tip,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildThinkingIndicator(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: TabTheme.speaking.accent,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Lito está analizando y generando respuesta...',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: TabTheme.speaking.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(AudioRecorderController recorder, bool isRecording, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131722) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: [
          // Input de texto
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFCBD5E1),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      enabled: !_isProcessing && !isRecording,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSendMessage(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        hintText: isRecording
                            ? 'Grabando tu voz...'
                            : 'Escribe tu respuesta en inglés...',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  if (_textController.text.trim().isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.send_rounded, color: TabTheme.speaking.accent, size: 20),
                      onPressed: _isProcessing ? null : () => _handleSendMessage(),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Botón Micrófono Pulsante / Mantener para hablar
          GestureDetector(
            onTap: _isProcessing
                ? null
                : () {
                    if (isRecording) {
                      _stopRecordingAndSend();
                    } else {
                      _startRecording();
                    }
                  },
            child: AnimatedBuilder(
              animation: _pulseAnimController,
              builder: (context, child) {
                final scale = isRecording ? (1.0 + _pulseAnimController.value * 0.15) : 1.0;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: isRecording
                            ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                            : [TabTheme.speaking.accent, const Color(0xFF0284C7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isRecording ? const Color(0xFFEF4444) : TabTheme.speaking.accent)
                              .withValues(alpha: isRecording ? 0.6 : 0.35),
                          blurRadius: isRecording ? 16 : 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
