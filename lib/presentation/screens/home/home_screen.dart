import 'package:flutter/material.dart';
import 'package:ikili_app/core/theme/app_theme.dart';
import 'package:ikili_app/presentation/widgets/ikili_logo.dart';
import 'package:ikili_app/presentation/widgets/primary_action_button.dart';
import 'package:ikili_app/presentation/widgets/room_code_input.dart';
import 'package:ikili_app/presentation/widgets/secondary_action_button.dart';
import 'package:ikili_app/presentation/widgets/stat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _roomCodeController = RoomCodeController();

  @override
  void dispose() {
    _roomCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. "İKİLİ." logosu
                const IkiliLogo(),

                const SizedBox(height: 24),

                // 2. "MERHABA {isim}"
                Text("Merhaba {isim}", style: AppTheme.eyebrow),

                // 3. "Bugün kim kimi daha iyi tanıyor?"
                Text("Bugün kim kimi daha iyi tanıyor?", style: AppTheme.heading),

                const SizedBox(height: 24),

                // 4. İstatistik kutuları
                const Row(
                  children: [
                    Expanded(
                      child: StatCard(value: '%30', label: 'ortalama isabet'),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: StatCard(value: '12', label: 'tamamlanan tur'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 5. "Oda Oluştur" butonu
                PrimaryActionButton(
                  title: 'Oda oluştur',
                  subtitle: 'Sen soruyorsun',
                  onPressed: () {},
                ),

                const SizedBox(height: 32),

                Text('KOD İLE KATIL', style: AppTheme.eyebrow),
                const SizedBox(height: 12),

                // 6. Oda kodu girişi
                RoomCodeInput(
                  controller: _roomCodeController,
                  onCompleted: (code) {},
                ),

                const SizedBox(height: 12),

                // 7. "Odaya Katıl" butonu
                SecondaryActionButton(label: 'Odaya Katıl', onPressed: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
