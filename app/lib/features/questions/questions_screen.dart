import 'package:flutter/material.dart';
import '../../core/extensions/l10n_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tab_theme.dart';
import '../vocabulary/vocabulary_repository.dart';
import '../../core/models/api_models.dart';
import '../../core/providers/app_providers.dart';

class QuestionsScreen extends ConsumerStatefulWidget {
  const QuestionsScreen({super.key});

  @override
  ConsumerState<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends ConsumerState<QuestionsScreen> {
  List<QuestionOut> _questions = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedCategory = 'all';
  String _selectedCefrLevel = 'all';
  bool _hasUserSelectedCefr = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final api = ref.read(apiClientProvider);
    try {
      final list = await api.getQuestions(
        category: _selectedCategory == 'all' ? null : _selectedCategory,
      );
      setState(() {
        _questions = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(activeProfileProvider).valueOrNull;
    if (!_hasUserSelectedCefr && profile != null) {
      _selectedCefrLevel = TabTheme.defaultPillForUserLevel(profile.targetLevel);
    }

    final filtered = _questions.where((q) {
      if (_selectedCefrLevel != 'all') {
        final qCefr = q.cefr ?? q.difficulty;
        if (!Cefr.matchesPill(qCefr, _selectedCefrLevel)) return false;
      }
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return q.title.toLowerCase().contains(query) || q.text.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.questionsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchQuestions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: context.l10n.questionsSearchHint,
                prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textSecondary),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: TabTheme.cefrRail.map((lvl) {
                final isSelected = _selectedCefrLevel.toLowerCase() == lvl['id']!.toLowerCase();
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: TabTheme.filterLevelPill(
                    id: lvl['id']!,
                    label: lvl['es']!,
                    isSelected: isSelected,
                    onTap: () => setState(() {
                      if (_selectedCefrLevel.toLowerCase() == lvl['id']!.toLowerCase()) {
                        _selectedCefrLevel = 'all';
                      } else {
                        _selectedCefrLevel = lvl['id']!;
                      }
                      _hasUserSelectedCefr = true;
                    }),
                  ),
                );
              }).toList(),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildFilterChip('all', 'Todas'),
                _buildFilterChip('tech', 'Technical'),
                _buildFilterChip('hr', 'HR & STAR'),
                _buildFilterChip('vocab', 'Vocabulary'),
              ],
            ),
          ),
          const Divider(height: 16, color: Color(0xFF334155)),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.error),
                              const SizedBox(height: 12),
                              Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary)),
                              const SizedBox(height: 16),
                              ElevatedButton(onPressed: _fetchQuestions, child: Text(context.l10n.errorRetry)),
                            ],
                          ),
                        ),
                      )
                    : filtered.isEmpty
                        ? Center(child: Text(context.l10n.questionsNoResults))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final q = filtered[index];
                              return _buildQuestionItem(q);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String id, String label) {
    final isSelected = _selectedCategory == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppTheme.primary.withValues(alpha: 0.25),
        checkmarkColor: AppTheme.primaryLight,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryLight : AppTheme.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (val) {
          if (val) {
            setState(() => _selectedCategory = id);
            _fetchQuestions();
          }
        },
      ),
    );
  }

  Widget _buildQuestionItem(QuestionOut q) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _difficultyColor(q.difficulty).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  q.difficulty.toUpperCase(),
                  style: TextStyle(color: _difficultyColor(q.difficulty), fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  q.title,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              q.text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Color(0xFF334155)),
                  Text(context.l10n.questionsFullQuestion, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(q.text, style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                  if (q.model_answer != null && q.model_answer!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(context.l10n.questionsModelAnswer, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.accent)),
                    const SizedBox(height: 4),
                    Text(q.model_answer!, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                  ],
                  if (q.tips != null && q.tips!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(context.l10n.questionsInterviewTip, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.warning)),
                    const SizedBox(height: 4),
                    Text(q.tips!, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.mic_rounded, size: 18),
                      label: Text(context.l10n.questionsPractice),
                      onPressed: () {
                        context.go('/?question_id=${q.id}');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _difficultyColor(String diff) {
    switch (diff.toLowerCase()) {
      case 'senior':
        return AppTheme.error;
      case 'mid':
        return AppTheme.warning;
      default:
        return AppTheme.accent;
    }
  }
}
