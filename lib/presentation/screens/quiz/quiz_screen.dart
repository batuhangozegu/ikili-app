import 'package:flutter/material.dart';
import 'package:ikili_app/core/theme/app_theme.dart';
import 'package:ikili_app/data/models/question_model.dart';
import 'package:ikili_app/data/repositories/question_repository.dart';
import 'package:ikili_app/presentation/screens/result/result_screen.dart';
import 'package:ikili_app/presentation/widgets/primary_action_button.dart';
import 'package:ikili_app/presentation/widgets/secondary_action_button.dart';

/// Soruları sırayla gösterip cevap toplayan tahmin ekranı.
/// WaitingRoomScreen'deki "Turu Başlat" butonundan açılır.
class QuizScreen extends StatefulWidget {
  final String roomId;

  const QuizScreen({super.key, required this.roomId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _questionRepository = QuestionRepository();
  late final Future<List<Question>> _questionsFuture;

  int _currentIndex = 0;
  final List<String> _answers = [];
  final Map<int, List<String>> _optionsCache = {};

  String? _selectedOption;
  final _freeTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _questionsFuture = _questionRepository.fetchQuestions(widget.roomId);
  }

  @override
  void dispose() {
    _freeTextController.dispose();
    super.dispose();
  }

  List<String> _optionsFor(int index, Question question) {
    return _optionsCache.putIfAbsent(index, () {
      final options = [...question.wrongOptions, question.correctAnswer];
      options.shuffle();
      return options;
    });
  }

  void _submitAnswer(List<Question> questions) {
    final question = questions[_currentIndex];
    final answer = question.type == QuestionType.multipleChoice
        ? (_selectedOption ?? '')
        : _freeTextController.text.trim();
    if (answer.isEmpty) return;

    _answers.add(answer);

    if (_currentIndex == questions.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            roomId: widget.roomId,
            questions: questions,
            answers: _answers,
          ),
        ),
      );
      return;
    }

    setState(() {
      _currentIndex++;
      _selectedOption = null;
      _freeTextController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tahmin Et')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: FutureBuilder<List<Question>>(
            future: _questionsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Sorular yüklenirken bir hata oluştu',
                    style: AppTheme.body,
                  ),
                );
              }
              final questions = snapshot.data ?? [];
              if (questions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Bu odada henüz soru yok', style: AppTheme.body),
                      const SizedBox(height: 16),
                      SecondaryActionButton(
                        label: 'Geri Dön',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                );
              }

              final question = questions[_currentIndex];
              final options = question.type == QuestionType.multipleChoice
                  ? _optionsFor(_currentIndex, question)
                  : const <String>[];
              final canSubmit = question.type == QuestionType.multipleChoice
                  ? _selectedOption != null
                  : _freeTextController.text.trim().isNotEmpty;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Soru ${_currentIndex + 1}/${questions.length}',
                    style: AppTheme.eyebrow,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    question.text,
                    style: AppTheme.heading.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 24),

                  if (question.type == QuestionType.multipleChoice)
                    Expanded(
                      child: ListView.separated(
                        itemCount: options.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final option = options[index];
                          final isSelected = option == _selectedOption;
                          return _OptionTile(
                            label: option,
                            isSelected: isSelected,
                            onTap: () =>
                                setState(() => _selectedOption = option),
                          );
                        },
                      ),
                    )
                  else
                    TextField(
                      controller: _freeTextController,
                      decoration: const InputDecoration(
                        hintText: 'Tahminini yaz',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),

                  if (question.type == QuestionType.freeText) const Spacer(),

                  const SizedBox(height: 16),

                  PrimaryActionButton(
                    title: _currentIndex == questions.length - 1
                        ? 'Bitir'
                        : 'Sonraki',
                    onPressed: canSubmit
                        ? () => _submitAnswer(questions)
                        : null,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accent.withValues(alpha: 0.15)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.accent : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
