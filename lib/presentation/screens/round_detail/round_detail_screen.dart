import 'package:flutter/material.dart';
import 'package:ikili_app/core/theme/app_theme.dart';
import 'package:ikili_app/data/models/room_model.dart';
import 'package:ikili_app/data/repositories/room_repository.dart';
import 'package:ikili_app/presentation/widgets/stat_card.dart';

class RoundDetailScreen extends StatelessWidget {
  const RoundDetailScreen({super.key, required this.roomId});

  final String roomId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tur Detayı')),
      body: SafeArea(
        child: StreamBuilder<Room>(
          stream: RoomRepository().watchRoom(roomId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final room = snapshot.data!;
            final answers = room.answers ?? [];
            final total = room.totalQuestions ?? 0;
            final score = room.score ?? 0;
            final percentage = total == 0 ? 0 : ((score / total) * 100).round();

            if (answers.isEmpty) {
              return Center(
                child: Text('Bu tur için kayıtlı cevap yok', style: AppTheme.body),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(value: '$score/$total', label: 'doğru tahmin'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(value: '%$percentage', label: 'isabet oranı'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Sorular', style: AppTheme.eyebrow),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: answers.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final entry = answers[index];
                        final isCorrect = entry['isCorrect'] as bool? ?? false;
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
                                      entry['questionText'] as String? ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Doğru cevap: ${entry['correctAnswer'] ?? ''}',
                                      style: AppTheme.body,
                                    ),
                                    Text(
                                      'Tahmin: ${entry['givenAnswer'] ?? ''}',
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
