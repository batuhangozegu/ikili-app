import 'package:flutter/material.dart';
import 'package:ikili_app/core/theme/app_theme.dart';
import 'package:ikili_app/data/service/preferences_service.dart';
import 'package:ikili_app/presentation/screens/add_questions/add_questions_screen.dart';
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
  String? _lastRoomId;

  @override
  void initState() {
    super.initState();
    _loadLastRoom();
  }

  @override
  void dispose() {
    _roomCodeController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Oda Bulunamadı'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadLastRoom() async {
    final prefsService = PreferencesService();
    final roomId = await prefsService.getLastRoomId();
    if (mounted) {
      setState(() {
        _lastRoomId = roomId;
      });
    }
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
              AddQuestionsScreen(roomId: roomViewModel.createdRoomId!),
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
                Text(
                  "Bugün kim kimi daha iyi tanıyor?",
                  style: AppTheme.heading,
                ),

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

                if (_lastRoomId != null) ...[
                  PrimaryActionButton(
                    title: 'Kaldığın Yerden Devam Et',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              WaitingRoomScreen(roomId: _lastRoomId!),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],

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

                SecondaryActionButton(
                  label: 'Odaya Katıl',
                  onPressed: () async {
                    final authViewModel = context.read<AuthViewModel>();
                    final roomViewModel = context.read<RoomViewModel>();

                    final userId = authViewModel.currentUser?.uid;
                    if (userId == null) return;

                    await roomViewModel.joinRoom(
                      _roomCodeController.code,
                      userId,
                    );
                    if (!context.mounted) return;

                    if (roomViewModel.errorMessage != null) {
                      _showErrorDialog(roomViewModel.errorMessage!);
                      return;
                    }

                    if (roomViewModel.createdRoomId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WaitingRoomScreen(
                            roomId: roomViewModel.createdRoomId!,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
