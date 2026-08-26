import 'package:flutter/material.dart';
import 'package:ikili_app/core/theme/app_theme.dart';
import 'package:ikili_app/data/models/room_model.dart';
import 'package:ikili_app/data/repositories/room_repository.dart';
import 'package:ikili_app/data/service/preferences_service.dart';
import 'package:ikili_app/presentation/screens/quiz/quiz_screen.dart';
import 'package:ikili_app/presentation/screens/round_detail/round_detail_screen.dart';
import 'package:ikili_app/presentation/viewmodels/auth_view_model.dart';
import 'package:ikili_app/presentation/widgets/primary_action_button.dart';
import 'package:provider/provider.dart';

class WaitingRoomScreen extends StatefulWidget {
  final String roomId;

  const WaitingRoomScreen({super.key, required this.roomId});

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen>
    with WidgetsBindingObserver {
  final _roomRepository = RoomRepository();
  final _preferencesService = PreferencesService();
  Room? _room;
  bool _roomClosed = false;
  // Aynı odaya iki kez otomatik navigate etmeyi önler (stream her snapshot'ta
  // build'i tetikliyor).
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Ekrandan ayrılırken (geri tuşu vb.) rakip hâlâ katılmadıysa odayı kapat.
    _closeRoomIfAbandoned();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Uygulama arka plana atıldığında/kapatıldığında da aynı kontrolü yap.
    // Not: uygulama "recents"ten tamamen kaydırılarak öldürülürse işletim
    // sistemi bu kodun çalışması için her zaman şans tanımayabilir; bu yüzden
    // kesin garanti isteniyorsa Firestore tarafında bir TTL politikası da
    // eklenmesi gerekir.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _closeRoomIfAbandoned();
    }
  }

  void _closeRoomIfAbandoned() {
    if (_roomClosed) return;
    final room = _room;
    // Rakip zaten katıldıysa ya da oda durumu değiştiyse iptal etme.
    if (room == null || room.opponentId != null) return;
    if (room.status != RoomStatus.waiting) return;

    _roomClosed = true;
    // Widget artık ekranda olmayabilir; sonucu beklemeden ateşle.
    _roomRepository.closeRoom(widget.roomId);
    // Ana ekrandaki "Kaldığın Yerden Devam Et" iptal edilmiş bu odayı bir
    // daha göstermesin diye kayıtlı son oda ID'sini de temizle.
    _preferencesService.clearLastRoomId();
  }

  void _navigateReplace(Widget screen) {
    if (_navigated) return;
    _navigated = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => screen),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthViewModel>().currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Oda')),
      body: StreamBuilder<Room>(
        stream: _roomRepository.watchRoom(widget.roomId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final room = snapshot.data!;
          _room = room;
          final opponentJoined = room.opponentId != null;
          final isCreator = userId != null && userId == room.creatorId;

          // Oda bitmişse (rakip tahmini tamamladı) herkesi sonuç ekranına
          // gönder; sadece cevaplayan kişi değil oda sahibi de görsün diye.
          if (room.status == RoomStatus.finished) {
            _navigateReplace(RoundDetailScreen(roomId: room.id));
          } else if (!isCreator && room.roundStarted) {
            // Tur başladı ve bu ekranı gören kişi rakip: doğrudan quiz'e geç.
            _navigateReplace(QuizScreen(roomId: room.id));
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Oda Kodu', style: AppTheme.eyebrow),
                const SizedBox(height: 8),
                Text(
                  room.code,
                  style: AppTheme.heading.copyWith(
                    fontSize: 40,
                    letterSpacing: 8,
                  ),
                ),

                const SizedBox(height: 32),

                Text(_statusText(opponentJoined, isCreator, room.roundStarted)),

                const Spacer(),

                if (isCreator)
                  PrimaryActionButton(
                    title: room.roundStarted ? 'Rakip Tahmin Ediyor...' : 'Turu Başlat',
                    onPressed: opponentJoined && !room.roundStarted
                        ? () => _roomRepository.startRound(room.id)
                        : null,
                  )
                else if (opponentJoined && !room.roundStarted)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          );
        },
      ),
    );
  }

  String _statusText(bool opponentJoined, bool isCreator, bool roundStarted) {
    if (!opponentJoined) return 'Rakip bekleniyor...';
    if (roundStarted) {
      return isCreator ? 'Rakip tahmin ediyor, biraz bekle 🎯' : 'Tur başlıyor...';
    }
    return isCreator
        ? 'Rakip katıldı! 🎉 Hazır olduğunda turu başlat.'
        : 'Rakip katıldın! Oda sahibinin turu başlatması bekleniyor...';
  }
}
