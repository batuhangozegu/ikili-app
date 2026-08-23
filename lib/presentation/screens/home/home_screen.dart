import 'package:flutter/material.dart';
import 'package:ikili_app/core/theme/app_theme.dart';
import 'package:ikili_app/presentation/screens/waiting_room/waiting_room_screen.dart';
import 'package:ikili_app/presentation/viewmodels/auth_view_model.dart';
import 'package:ikili_app/presentation/viewmodels/room_view_model.dart';
import 'package:ikili_app/presentation/widgets/ikili_logo.dart';
import 'package:ikili_app/presentation/widgets/primary_action_button.dart';
import 'package:ikili_app/presentation/widgets/room_code_input.dart';
import 'package:ikili_app/presentation/widgets/secondary_action_button.dart';
import 'package:ikili_app/presentation/widgets/stat_card.dart';
import 'package:provider/provider.dart';

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

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _createRoom() async {
    final authViewModel = context.read<AuthViewModel>();
    final roomViewModel = context.read<RoomViewModel>();

    final userId = authViewModel.currentUser?.uid;
    if (userId == null) {
      _showSnack('Oda oluşturmak için giriş yapmalısınız');
      return;
    }

    await roomViewModel.createRoom(userId);
    if (!context.mounted) return;

    if (roomViewModel.errorMessage != null) {
      _showSnack(roomViewModel.errorMessage!);
      return;
    }

    if (roomViewModel.createdRoomId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              WaitingRoomScreen(roomId: roomViewModel.createdRoomId!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCreatingRoom = context.watch<RoomViewModel>().isLoading;

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
                  isLoading: isCreatingRoom,
                  onPressed: _createRoom,
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
                // TODO: RoomRepository'de joinRoom(code, userId) henüz yok.
                // Eklenene kadar bu buton oda oluşturmuyor/katılmıyor.
                SecondaryActionButton(
                  label: 'Odaya Katıl',
                  onPressed: () => _showSnack('Kod ile katılma yakında'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
