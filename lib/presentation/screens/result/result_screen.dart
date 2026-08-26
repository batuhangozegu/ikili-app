import 'package:flutter/material.dart';
import 'package:ikili_app/core/theme/app_theme.dart';
import 'package:ikili_app/data/models/question_model.dart';
import 'package:ikili_app/data/repositories/room_repository.dart';
import 'package:ikili_app/data/service/preferences_service.dart';
import 'package:ikili_app/presentation/screens/main_navigation/main_navigation_screen.dart';
import 'package:ikili_app/presentation/widgets/primary_action_button.dart';
import 'package:ikili_app/presentation/widgets/stat_card.dart';

/// Skoru hesaplayan, karşılaştırmayı gösteren ve odayı "finished" yapan
/// sonuç ekranı. QuizScreen'den son sorudan sonra açılır.
class ResultScreen extends StatefulWidget {
  final String roomId;
  final List<Question> questions;
  final List<String> answers;

  const ResultScreen({
    super.key,
    required this.roomId,
    required this.questions,
    required this.answers,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _roomRepository = RoomRepository();
  late final List<Map<String, dynamic>> _breakdown;
  late final int _score;

  bool _isCorrect(Question question, String given) {
    return given.trim().toLowerCase() ==
        question.correctAnswer.trim().toLowerCase();
  }

  @override
  void initState() {
    super.initState();

    _breakdown = [];
    var score = 0;
    for (var i = 0; i < widget.questions.length; i++) {
      final question = widget.questions[i];
      final given = i < widget.answers.length ? widget.answers[i] : '';
      final correct = _isCorrect(question, given);
      if (correct) score++;
      _breakdown.add({
        'questionText': question.text,
        'correctAnswer': question.correctAnswer,
        'givenAnswer': given,
        'isCorrect': correct,
      });
    }
    _score = score;

    _roomRepository.finishRoom(
      widget.roomId,
      score: _score,
      totalQuestions: widget.questions.length,
      answers: _breakdown,
    );
    PreferencesService().clearLastRoomId();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.questions.length;
    final percentage = total == 0 ? 0 : ((_score / total) * 100).round();

    return Scaffold(
      appBar: AppBar(title: const Text('Sonuç')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatCard(value: '$_score/$total', label: 'doğru tahmin'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(value: '%$percentage', label: 'isabet oranı'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Text('Karşılaştırma', style: AppTheme.eyebrow),
              const SizedBox(height: 12),

              Expanded(
                child: ListView.separated(
                  itemCount: _breakdown.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final entry = _breakdown[index];
                    final isCorrect = entry['isCorrect'] as bool;
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            isCorrect ? Icons.check_circle : Icons.cancel,
                            color: isCorrect ? Colors.green : AppTheme.accent,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry['questionText'] as String,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Doğru cevap: ${entry['correctAnswer']}',
                                  style: AppTheme.body,
                                ),
                                Text(
                                  'Senin tahminin: ${entry['givenAnswer']}',
                                  style: AppTheme.body,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              PrimaryActionButton(
                title: 'Ana Ekrana Dön',
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const MainNavigationScreen(),
                    ),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
