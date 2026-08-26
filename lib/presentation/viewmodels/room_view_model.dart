import 'package:ikili_app/data/repositories/room_repository.dart';
import 'package:ikili_app/data/service/preferences_service.dart';
import 'package:ikili_app/presentation/viewmodels/async_view_model.dart';

class RoomViewModel extends AsyncViewModel {
  final RoomRepository _roomRepository = RoomRepository();
  final PreferencesService _preferencesService = PreferencesService();

  String? _createdRoomId;
  String? get createdRoomId => _createdRoomId;

  Future<void> createRoom(String creatorId) async {
    final roomId = await runAsync(
      () => _roomRepository.createRoom(creatorId),
      onError: (_) => 'Oda oluşturulurken bir hata oluştu',
    );
    if (roomId != null) {
      _createdRoomId = roomId;
      await _preferencesService.saveLastRoomId(roomId);
    }
  }

  Future<void> joinRoom(String code, String opponentId) async {
    _createdRoomId = null;
    final room = await runAsync(
      () => _roomRepository.joinRoom(code, opponentId),
      onError: (_) => 'Oda bulunamadı ya da süresi doldu',
    );
    if (room != null) {
      _createdRoomId = room.id;
     await _preferencesService.saveLastRoomId(room.id);
    }
  }
}
