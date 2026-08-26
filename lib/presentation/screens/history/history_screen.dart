import 'package:flutter/material.dart';
import 'package:ikili_app/core/theme/app_theme.dart';
import 'package:ikili_app/data/models/room_model.dart';
import 'package:ikili_app/data/repositories/room_repository.dart';
import 'package:ikili_app/data/repositories/user_repository.dart';
import 'package:ikili_app/presentation/screens/history/widgets/history_round_tile.dart';
import 'package:ikili_app/presentation/screens/round_detail/round_detail_screen.dart';
import 'package:ikili_app/presentation/viewmodels/auth_view_model.dart';
import 'package:ikili_app/presentation/widgets/stat_card.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthViewModel>().currentUser?.uid;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Geçmiş', style: AppTheme.heading.copyWith(fontSize: 24)),

              const SizedBox(height: 24),

              Expanded(
                child: userId == null
                    ? _EmptyState()
                    : StreamBuilder<List<Room>>(
                        stream: RoomRepository().watchFinishedRooms(userId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final rooms = snapshot.data ?? [];
                          if (rooms.isEmpty) {
                            return const _EmptyState();
                          }

                          final average = rooms
                                  .map((r) => r.totalQuestions == null ||
                                          r.totalQuestions == 0
                                      ? 0
                                      : (r.score ?? 0) / r.totalQuestions!)
                                  .fold<double>(0, (a, b) => a + b) /
                              rooms.length;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: StatCard(
                                      value: '%${(average * 100).round()}',
                                      label: 'senin ortalaman',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: StatCard(
                                      value: '${rooms.length}',
                                      label: 'oynanan oyun sayısı',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: rooms.length,
                                  itemBuilder: (context, index) {
                                    final room = rooms[index];
                                    final total = room.totalQuestions ?? 0;
                                    final score = room.score ?? 0;
                                    final percentage = total == 0
                                        ? 0
                                        : ((score / total) * 100).round();
                                    final opponentId =
                                        room.creatorId == userId
                                            ? room.opponentId
                                            : room.creatorId;

                                    return FutureBuilder<String>(
                                      future: opponentId == null
                                          ? Future.value('Rakip')
                                          : UserRepository()
                                              .fetchUser(opponentId)
                                              .then((u) => u?.displayName ?? 'Rakip'),
                                      builder: (context, nameSnapshot) {
                                        final opponentName =
                                            nameSnapshot.data ?? '...';
                                        return HistoryRoundTile(
                                          percentageLabel: '%$percentage',
                                          title: opponentName,
                                          subtitle:
                                              '$score/$total doğru · ${_formatDate(room.finishedAt)}',
                                          onTap: () => _openRoundDetail(
                                            context,
                                            room.id,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  void _openRoundDetail(BuildContext context, String roomId) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => RoundDetailScreen(roomId: roomId)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text('Henüz tamamlanmış bir tur yok', style: AppTheme.body),
        ],
      ),
    );
  }
}
