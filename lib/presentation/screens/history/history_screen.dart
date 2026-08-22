import 'package:flutter/material.dart';
import 'package:ikili_app/core/theme/app_theme.dart';
import 'package:ikili_app/presentation/screens/history/widgets/history_round_tile.dart';
import 'package:ikili_app/presentation/screens/round_detail/round_detail_screen.dart';
import 'package:ikili_app/presentation/widgets/stat_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Geçmiş', style: AppTheme.heading.copyWith(fontSize: 24)),

              const SizedBox(height: 24),

              const Row(
                children: [
                  Expanded(
                    child: StatCard(value: '%20', label: 'senin ortalaman'),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: StatCard(value: '12', label: 'oynanan oyun sayısı'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Expanded(
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    const title = "Ozan'ı tahmin ettin";
                    return HistoryRoundTile(
                      percentageLabel: '%${60 + index * 5}',
                      title: title,
                      subtitle: '12 Ağustos - 4/5 doğru',
                      onTap: () => _openRoundDetail(context, title),
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

  void _openRoundDetail(BuildContext context, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => RoundDetailScreen(title: title)),
    );
  }
}
