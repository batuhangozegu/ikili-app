import 'package:flutter/material.dart';
import 'package:ikili_app/core/theme/app_theme.dart';
import 'package:ikili_app/data/models/question_model.dart';
import 'package:ikili_app/data/repositories/question_repository.dart';
import 'package:ikili_app/presentation/screens/waiting_room/waiting_room_screen.dart';
import 'package:ikili_app/presentation/viewmodels/auth_view_model.dart';
import 'package:ikili_app/presentation/widgets/labeled_text_field.dart';
import 'package:ikili_app/presentation/widgets/primary_action_button.dart';
import 'package:ikili_app/presentation/widgets/secondary_action_button.dart';
import 'package:provider/provider.dart';

class AddQuestionsScreen extends StatefulWidget {
  final String roomId;

  const AddQuestionsScreen({super.key, required this.roomId});

  @override
  State<AddQuestionsScreen> createState() => _AddQuestionsScreenState();
}

class _AddQuestionsScreenState extends State<AddQuestionsScreen> {
  final _questionRepository = QuestionRepository();

  final _questionController = TextEditingController();
  final _correctAnswerController = TextEditingController();
  final _wrongOption1Controller = TextEditingController();
  final _wrongOption2Controller = TextEditingController();
  final _wrongOption3Controller = TextEditingController();

  QuestionType _selectedType = QuestionType.multipleChoice;
  bool _isSaving = false;

  @override
  void dispose() {
    _questionController.dispose();
    _correctAnswerController.dispose();
    _wrongOption1Controller.dispose();
    _wrongOption2Controller.dispose();
    _wrongOption3Controller.dispose();
    super.dispose();
  }

  Future<void> _addQuestion() async {
    if (_questionController.text.trim().isEmpty ||
        _correctAnswerController.text.trim().isEmpty) {
      return;
    }
    if (_selectedType == QuestionType.multipleChoice &&
        (_wrongOption1Controller.text.trim().isEmpty ||
            _wrongOption2Controller.text.trim().isEmpty ||
            _wrongOption3Controller.text.trim().isEmpty)) {
      return;
    }

    final userId = context.read<AuthViewModel>().currentUser?.uid ?? '';

    setState(() => _isSaving = true);
    try {
      await _questionRepository.addQuestion(
        roomId: widget.roomId,
        type: _selectedType,
        text: _questionController.text.trim(),
        correctAnswer: _correctAnswerController.text.trim(),
        wrongOptions: _selectedType == QuestionType.multipleChoice
            ? [
                _wrongOption1Controller.text.trim(),
                _wrongOption2Controller.text.trim(),
                _wrongOption3Controller.text.trim(),
              ]
            : [],
        createdBy: userId,
      );
      _questionController.clear();
      _correctAnswerController.clear();
      _wrongOption1Controller.clear();
      _wrongOption2Controller.clear();
      _wrongOption3Controller.clear();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _removeQuestion(Question question) {
    _questionRepository.deleteQuestion(widget.roomId, question.id);
  }

  void _goToWaitingRoom() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => WaitingRoomScreen(roomId: widget.roomId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soru Ekle'),
        actions: [
          TextButton(
            onPressed: _goToWaitingRoom,
            child: const Text('Devam Et'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _QuestionTypeToggle(
                selectedType: _selectedType,
                onTypeChanged: (type) => setState(() => _selectedType = type),
              ),

              const SizedBox(height: 16),

              LabeledTextField(
                label: 'Soru',
                hint: 'Soruyu yaz',
                controller: _questionController,
              ),

              const SizedBox(height: 16),

              LabeledTextField(
                label: 'Doğru Cevap',
                hint: 'Doğru cevabı yaz',
                controller: _correctAnswerController,
              ),

              if (_selectedType == QuestionType.multipleChoice) ...[
                const SizedBox(height: 16),
                LabeledTextField(
                  label: 'Yanlış Şık',
                  hint: 'Bir yanlış cevap yaz',
                  controller: _wrongOption1Controller,
                ),
                const SizedBox(height: 16),
                LabeledTextField(
                  label: 'Yanlış Şık',
                  hint: 'Bir yanlış cevap daha yaz',
                  controller: _wrongOption2Controller,
                ),
                const SizedBox(height: 16),
                LabeledTextField(
                  label: 'Yanlış Şık',
                  hint: 'Son yanlış cevabı yaz',
                  controller: _wrongOption3Controller,
                ),
              ],

              const SizedBox(height: 16),

              PrimaryActionButton(
                title: 'Soruyu Ekle',
                icon: Icons.add,
                isLoading: _isSaving,
                onPressed: _addQuestion,
              ),

              const SizedBox(height: 24),

              Expanded(
                child: StreamBuilder<List<Question>>(
                  stream: _questionRepository.watchQuestions(widget.roomId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final questions = snapshot.data ?? [];
                    if (questions.isEmpty) {
                      return Center(
                        child: Text(
                          'Henüz soru eklemedin',
                          style: AppTheme.body,
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        final question = questions[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  question.text,
                                  style: AppTheme.body,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => _removeQuestion(question),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              SecondaryActionButton(
                label: 'Bekleme Odasına Geç',
                onPressed: _goToWaitingRoom,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Soru ekranına özel "Çoktan Seçmeli / Serbest Metin" segmentli seçim
/// widget'ı. AuthModeToggle ile aynı desen, bool yerine QuestionType taşır.
class _QuestionTypeToggle extends StatelessWidget {
  final QuestionType selectedType;
  final ValueChanged<QuestionType> onTypeChanged;

  const _QuestionTypeToggle({
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleOption(
              label: 'Çoktan Seçmeli',
              isSelected: selectedType == QuestionType.multipleChoice,
              onTap: () => onTypeChanged(QuestionType.multipleChoice),
            ),
          ),
          Expanded(
            child: _ToggleOption(
              label: 'Serbest Metin',
              isSelected: selectedType == QuestionType.freeText,
              onTap: () => onTypeChanged(QuestionType.freeText),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  const _ToggleOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
