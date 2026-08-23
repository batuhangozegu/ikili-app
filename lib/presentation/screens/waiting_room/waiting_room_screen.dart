import 'package:flutter/material.dart';
import 'package:ikili_app/core/theme/app_theme.dart';
import 'package:ikili_app/data/models/room_model.dart';
import 'package:ikili_app/data/repositories/room_repository.dart';
import 'package:ikili_app/presentation/widgets/primary_action_button.dart';

class WaitingRoomScreen extends StatefulWidget {
  final String roomId;

  const WaitingRoomScreen({super.key, required this.roomId});

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen>
    with WidgetsBindingObserver {
  final _roomRepository = RoomRepository();
  Room? _room;
  bool _roomClosed = false;

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
  }

  @override
  Widget build(BuildContext context) {
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

                Text(opponentJoined ? 'Rakip katıldı! 🎉' : 'Rakip bekleniyor...'),

                Spacer(),

                PrimaryActionButton(
                  title: "Turu Başlat",
                  onPressed: opponentJoined ? () {} : null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
